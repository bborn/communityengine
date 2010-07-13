require 'hpricot'
require 'open-uri'
require 'pp'

class BaseController < ApplicationController
  include AuthenticatedSystem
  include LocalizedApplication
  around_filter :set_locale  
  skip_before_filter :verify_authenticity_token, :only => :footer_content
  helper_method :commentable_url
  before_filter :initialize_header_tabs
  before_filter :initialize_admin_tabs

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
    @posts = Post.find_recent

    @rss_title = "#{AppConfig.community_name} "+:recent_posts.l
    @rss_url = rss_url
    respond_to do |format|
      format.html { get_additional_homepage_data }
      format.rss do
        render_rss_feed_for(@posts, { :feed => {:title => "#{AppConfig.community_name} "+:recent_posts.l, :link => recent_url},
                              :item => {:title => :title,
                                        :link =>  Proc.new {|post| user_post_url(post.user, post)},
                                         :description => :post,
                                         :pub_date => :published_at}
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
    
  def advertise
  end
  
  def css_help
  end
  
  
  private
    def admin_required
      current_user && current_user.admin? ? true : access_denied
    end
  
    def admin_or_moderator_required
      current_user && (current_user.admin? || current_user.moderator?) ? true : access_denied
    end
  
    def find_user
      if @user = User.active.find(params[:user_id] || params[:id])
        @is_current_user = (@user && @user.eql?(current_user))
        unless logged_in? || @user.profile_public?
          flash[:error] = :this_users_profile_is_not_public_youll_need_to_create_an_account_and_log_in_to_access_it.l
          access_denied 
        else
          return @user
        end
      else
        flash[:error] = :please_log_in.l
        access_denied
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
      sql += " GROUP BY tags.id, tags.name"
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


    def commentable_url(comment)
      if comment.recipient && comment.commentable
        if comment.commentable_type != "User"
          polymorphic_url([comment.recipient, comment.commentable])+"#comment_#{comment.id}"
        elsif comment
          user_url(comment.recipient)+"#comment_#{comment.id}"
        end
      elsif comment.commentable
        polymorphic_url(comment.commentable)+"#comment_#{comment.id}"      
      end
    end

    def commentable_comments_url(commentable)
      if commentable.owner && commentable.owner != commentable
        "#{polymorphic_path([commentable.owner, commentable])}#comments"      
      else
        "#{polymorphic_path(commentable)}#comments"      
      end    
    end 
    
    def initialize_header_tabs
      # This hook allows plugins or host apps to easily add tabs to the header by adding to the @header_tabs array
      # Usage: @header_tabs << {:name => "My tab", :url => my_tab_path, :section => 'my_tab_section' }
      @header_tabs = []      
    end 
    def initialize_admin_tabs
      # This hook allows plugins or host apps to easily add tabs to the admin nav by adding to the @admin_nav_links array
      # Usage: @admin_nav_links << {:name => "My link", :url => my_link_path,  }
      @admin_nav_links = []      
    end 

end
