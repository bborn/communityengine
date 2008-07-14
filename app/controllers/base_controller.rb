require 'hpricot'
require 'open-uri'
require 'pp'

class BaseController < ApplicationController
  include AuthenticatedSystem
  around_filter :set_locale  
  before_filter :login_from_cookie  
  skip_before_filter :verify_authenticity_token, :only => :footer_content
    
  caches_action :site_index, :footer_content, :if => Proc.new{|c| c.cache_action? }
  def cache_action?
    !logged_in? && controller_name.eql?('base') && params[:format].blank? 
  end  
  
  if AppConfig.closed_beta_mode
    before_filter :beta_login_required, :except => [:teaser]
  end    
  
  def teaser
    redirect_to home_path and return if logged_in?
    render :layout => 'beta'
  end
  
  def rss_site_index
    redirect_to :controller => 'base', :action => 'site_index', :format => 'rss'
  end
  
  def plaxo
    render :layout => false
  end

  def site_index    
    @posts = Post.find_recent(:limit => 16)

    @rss_title = "#{AppConfig.community_name} Recent Posts"
    @rss_url = rss_url
    respond_to do |format|     
      format.html { get_additional_homepage_data }
      format.rss do
        render_rss_feed_for(@posts, { :feed => {:title => "#{AppConfig.community_name} Recent Posts", :link => recent_url},
          :item => {:title => :title, :link => :link_for_rss, :description => :post, :pub_date => :published_at} 
          })        
      end
    end    
  end
  
  def footer_content
    get_recent_footer_content 
    render :partial => 'shared/footer_content' and return    
  end
  
  def homepage_features
    @homepage_features = HomepageFeature.find_features
    @homepage_features.shift
    render :partial => 'homepage_feature', :collection => @homepage_features and return
  end
    
  def about
  end
  
  def advertise
  end
  
  def faq
  end
  
  def css_help
  end
  
  def admin_required
    current_user && current_user.admin? ? true : access_denied
  end
  
  def find_user
    if @user = User.find(params[:user_id] || params[:id])
      @is_current_user = (@user && @user.eql?(current_user))
      unless logged_in? || @user.profile_public?
        flash.now[:error] = "This user's profile is not public. You'll need to create an account and log in to access it."
        redirect_to :controller => 'sessions', :action => 'new'        
      end
      return @user
    else
      flash.now[:error] = "Please log in."
      redirect_to :controller => 'sessions', :action => 'new'
      return false
    end
  end
  
  def require_current_user
    @user ||= User.find(params[:user_id] || params[:id] )
    unless admin? || (@user && (@user.eql?(current_user)))
      redirect_to :controller => 'sessions', :action => 'new' and return false
    end
    return @user
  end

  def popular_tags(limit = nil, order = ' tags.name ASC', type = nil)
    sql = "SELECT tags.id, tags.name, count(*) AS count 
      FROM taggings, tags 
      WHERE tags.id = taggings.tag_id "
    sql += " AND taggings.taggable_type = '#{type}'" unless type.nil?      
    sql += " GROUP BY tag_id"
    sql += " ORDER BY #{order}"
    sql += " LIMIT #{limit}" if limit
    Tag.find_by_sql(sql).sort{ |a,b| a.name.downcase <=> b.name.downcase}
  end
  

  def get_recent_footer_content
    @recent_clippings = Clipping.find_recent(:limit => 10)
    @recent_photos = Photo.find_recent(:limit => 10)
    @recent_comments = Comment.find_recent(:limit => 13)
    @popular_tags = popular_tags(30, ' count DESC')
    @recent_activity = User.recent_activity(:size => 15, :current => 1)
    
  end

  def get_additional_homepage_data
    @sidebar_right = true
    @homepage_features = HomepageFeature.find_features
    @homepage_features_data = @homepage_features.collect {|f| [f.id, f.public_filename(:large) ]  }    
    
    @active_users = User.find_by_activity({:limit => 5, :require_avatar => false})
    @featured_writers = User.find_featured

    @featured_posts = Post.find_featured
    
    @topics = Topic.find(:all, :limit => 5, :order => "replied_at DESC")

    @active_contest = Contest.get_active
    @popular_posts = Post.find_popular({:limit => 10})    
    @popular_polls = Poll.find_popular(:limit => 8)
  end
  
 # Set the locale from the parameters, the session, or the navigator
  # If none of these works, the Globalite default locale is set (en-*)
  def set_locale
    # Get the current path and request method (useful in the layout for changing the language)
    @current_path = request.env['PATH_INFO']
    @request_method = request.env['REQUEST_METHOD']

    # Try to get the locale from the parameters, from the session, and then from the navigator
    if params[:user_locale]
        logger.debug "[globalite] #{params[:user_locale][:code]} locale passed"
        Locale.code = params[:user_locale][:code] 
        # Store the locale in the session
        session[:locale] = Locale.code
    elsif session[:locale]
        logger.debug "[globalite] loading locale: #{session[:locale]} from session"
        Locale.code = session[:locale]
    else
        Locale.code = get_valid_lang_from_accept_header
        logger.debug "[globalite] found a valid http header locale: #{Locale.code}"
    end
    
    logger.debug "[globalite] Locale set to #{Locale.code}"
    # render the page
    yield

    # reset the locale to its default value
    Locale.reset!
  end

  # Get a sorted array of the navigator languages
  def get_sorted_langs_from_accept_header
    accept_langs = (request.env['HTTP_ACCEPT_LANGUAGE'] || "en-us,en;q=0.5").split(/,/) rescue nil
    return nil unless accept_langs

    # Extract langs and sort by weight
    # Example HTTP_ACCEPT_LANGUAGE: "en-au,en-gb;q=0.8,en;q=0.5,ja;q=0.3"
    wl = {}
    accept_langs.each {|accept_lang|
        if (accept_lang + ';q=1') =~ /^(.+?);q=([^;]+).*/
            wl[($2.to_f rescue -1.0)]= $1
        end
    }
    logger.debug "[globalite] client accepted locales: #{wl.sort{|a,b| b[0] <=> a[0] }.map{|a| a[1] }.to_sentence}"
    sorted_langs = wl.sort{|a,b| b[0] <=> a[0] }.map{|a| a[1] }
  end

  # Returns a valid language that best suits the HTTP_ACCEPT_LANGUAGE request header.
  # If no valid language can be deduced, then <tt>nil</tt> is returned.
  def get_valid_lang_from_accept_header
    # Get the sorted navigator languages and find the first one that matches our available languages
    get_sorted_langs_from_accept_header.detect do |l|
  my_locale = get_matching_ui_locale(l)
        return my_locale if !my_locale.nil?
    end
  end

  # Returns the UI locale that best matches with the parameter
  # or nil if not found
  def get_matching_ui_locale(locale)
    lang = locale[0,2].downcase
    to_try = Array.new()
    if locale[3,5]
      country = locale[3,5].upcase
      logger.debug "[globalite] trying to match locale: #{lang}-#{country} and #{lang}-*"
      to_try << "#{lang}-#{country}".to_sym
      to_try << "#{lang}-*".to_sym
    else
      logger.debug "[globalite] trying to match #{lang}-*"
      to_try << "#{lang}-*".to_sym
    end

    # Check with exact matching
    to_try.each do |possible_locale|
      if Globalite.ui_locales.values.include?(possible_locale)
        logger.debug "[globalite] Globalite does include #{locale} matching #{possible_locale}"
        return possible_locale
      end
    end

    return nil

  end  

end