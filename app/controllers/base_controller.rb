require 'hpricot'
require 'open-uri'
require 'pp'

class BaseController < ApplicationController
  include AuthenticatedSystem
  before_filter :login_from_cookie  
  
  caches_action :site_index, :footer_content
  
  def cache_action?(action_name)
    !logged_in? && controller_name.eql?('base') && params[:format].blank?
  end
  def action_fragment_key(options)  
    url = url_for(options).split('://').last
    url = (url =~ /^.*\/$/) ? "#{url}index" : url
    url
  end    
  
  if AppConfig.closed_beta_mode
    before_filter :beta_login_required, :except => [:teaser]
  end    
  
  def teaser
    redirect_to home_path and return if current_user
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

    @rss_title = "Curbly Recent Posts"
    @rss_url = rss_url
    respond_to do |format|     
      format.html { get_additional_homepage_data }
      format.rss do
        render_rss_feed_for(@posts, { :feed => {:title => "#{AppConfig.community_name} Recent Posts", :link => recent_url},
          :item => {:title => :title, :link => :link_for_rss, :description => :post, :pub_date => :created_at} 
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

end