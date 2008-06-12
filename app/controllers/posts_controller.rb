class PostsController < BaseController
  include Viewable
  uses_tiny_mce(:options => AppConfig.default_mce_options, :only => [:new, :edit, :update, :create ])
  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:show])
         
  cache_sweeper :post_sweeper, :only => [:create, :update, :destroy]
  caches_action :show, :if => Proc.new{|c| c.cache_action? }
  def cache_action?
    !logged_in? && controller_name.eql?('posts')
  end  
                           
  before_filter :login_required, :only => [:new, :edit, :update, :destroy, :create, :manage]
  before_filter :find_user, :only => [:new, :edit, :index, :show, :update_view, :manage]
  before_filter :require_ownership_or_moderator, :only => [:create, :edit, :update, :destroy, :manage]

  def manage
    @posts = @user.posts.find_without_published_as(:all, :page => {:current => params[:page], :size => 10}, :order => 'published_at DESC')
  end

  def index
    @user = User.find(params[:user_id])            
    @category = Category.find_by_name(params[:category_name]) if params[:category_name]
    cond = Caboose::EZ::Condition.new
    cond.user_id == @user.id
    if @category
      cond.append ['category_id = ?', @category.id]
    end
    @pages, @posts = paginate :posts, :order => "published_at DESC", :conditions => cond.to_sql, :per_page => 20
    @is_current_user = @user.eql?(current_user)

    @popular_posts = @user.posts.find(:all, :limit => 10, :order => "view_count DESC")
    
    @rss_title = "#{AppConfig.community_name}: #{@user.login}'s posts"
    @rss_url = formatted_user_posts_path(@user,:rss)
        
    respond_to do |format|
      format.html # index.rhtml
      format.rss {
        render_rss_feed_for(@posts,
           { :feed => {:title => @rss_title, :link => url_for(:controller => 'posts', :action => 'index', :user_id => @user) },
             :item => {:title => :title,
                       :description => :post,
                       :link => :link_for_rss,
                       :pub_date => :published_at} })        
      }
    end
  end
  
  def popular
    @posts = Post.find(:all, :conditions => "published_at > '#{1.days.ago.to_s :db}'", :order => "view_count DESC")
  end
    
  # GET /posts/1
  # GET /posts/1.xml
  def show
    @rss_title = "#{AppConfig.community_name}: #{@user.login}'s posts"
    @rss_url = formatted_user_posts_path(@user,:rss)
    
    @post = Post.find(params[:id])
    @user = @post.user
    @is_current_user = @user.eql?(current_user)
    @comment = Comment.new(params[:comment])

    @comments = @post.comments.find(:all, :limit => 20, :order => 'created_at DESC')

    @previous = @post.previous_post
    @next = @post.next_post    
    @popular_posts = @user.posts.find(:all, :limit => 10, :order => "view_count DESC")    
    @related = Post.find_related_to(@post)
    @most_commented = Post.find_most_commented
    
    respond_to do |format|
      format.html
    end
  end
  
  def update_views
    @post = Post.find(params[:id])
    update_view_count(@post)
    render :nothing => true
  end
  
  def preview
    @user = current_user
  end
  
  # GET /posts/new
  def new
    @user = User.find(params[:user_id])    
    @post = Post.new(params[:post])
    @post.published_as = 'live'
  end
  
  # GET /posts/1;edit
  def edit
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.xml
  def create    
    @user = User.find(params[:user_id])
    @post = Post.new(params[:post])
    @post.user = @user
    respond_to do |format|
      if @post.save
        @post.create_poll(params[:poll], params[:choices]) if params[:poll]
        
        @post.tag_with(params[:tag_list] || '') 
        flash[:notice] = @post.category ? "Your '#{Inflector.singularize(@post.category.name)}' post was successfully created." : "Your post was successfully created."
        format.html { 
          if @post.is_live?
            redirect_to @post.category ? category_path(@post.category) : user_post_path(@user, @post) 
          else
            redirect_to manage_user_posts_path(@user)
          end
        }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    @post = Post.find(params[:id])
    @user = @post.user
    @post.tag_with(params[:tag_list] || '') 
    
    respond_to do |format|
      if @post.update_attributes(params[:post])
        @post.update_poll(params[:poll], params[:choices]) if params[:poll]
        
        format.html { redirect_to user_post_path(@post.user, @post) }
      else
        format.html { render :action => "edit" }  
      end
    end
  end
  
  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @user = User.find(params[:user_id])
    @post = Post.find(params[:id])
    @post.destroy
    
    respond_to do |format|
      format.html { 
        flash[:notice] = "Your post was deleted."
        redirect_to manage_user_posts_url(@user)   
        }
    end
  end
    
  def send_to_friend
    unless params[:emails]
      render :partial => 'posts/send_to_friend', :locals => {:user_id => params[:user_id], :post_id => params[:post_id]} and return
    end
    @post = Post.find(params[:id])
    if @post.send_to(params[:emails], params[:message], (current_user || nil))
      render :inline => "It worked!"            
    else
      render :inline => "You entered invalid addresses: <ul>"+ @post.invalid_emails.collect{|email| '<li>'+email+'</li>' }.join+"</ul> Please correct these and try again.", :status => 500
    end
  end


  def popular
    @posts = Post.find_popular({:limit => 15, :since => 3.days})

    @monthly_popular_posts = Post.find_popular({:limit => 20, :since => 30.days})
    
    @related_tags = Tag.find_by_sql("SELECT tags.id, tags.name, count(*) AS count 
      FROM taggings, tags 
      WHERE tags.id = taggings.tag_id GROUP BY tag_id");

    @rss_title = "#{AppConfig.community_name} Popular Posts"
    @rss_url = popular_rss_url    
    respond_to do |format|
      format.html # index.rhtml
      format.rss {
        render_rss_feed_for(@posts, { :feed => {:title => @rss_title, :link => popular_url},
          :item => {:title => :title, :link => :link_for_rss, :description => :post, :pub_date => :published_at} 
          })        
      }
    end
  end
  
  def recent
    @pages, @posts = paginate :posts, :order => "published_at DESC"

    @recent_clippings = Clipping.find_recent(:limit => 15)
    @recent_photos = Photo.find_recent(:limit => 10)
    
    @rss_title = "#{AppConfig.community_name} Recent Posts"
    @rss_url = recent_rss_url
    respond_to do |format|
      format.html 
      format.rss {
        render_rss_feed_for(@posts, { :feed => {:title => @rss_title, :link => recent_url},
          :item => {:title => :title, :link => :link_for_rss, :description => :post, :pub_date => :published_at} 
          })        
      }
    end    
  end
  
  def featured
    @pages, @posts = paginate :posts, :order => "posts.published_at DESC", :conditions => ["users.featured_writer = ?", true], :include => :user
    @featured_writers = User.find_featured    
        
    @rss_title = "#{AppConfig.community_name} Featured Posts"
    @rss_url = featured_rss_url
    respond_to do |format|
      format.html 
      format.rss {
        render_rss_feed_for(@posts, { :feed => {:title => @rss_title, :link => recent_url},
          :item => {:title => :title, :link => :link_for_rss, :description => :post, :pub_date => :published_at} 
          })        
      }
    end    
  end  
  
  def category_tips_update
    return unless request.xhr?
    @category = Category.find(params[:post_category_id] )
    render :partial => "/categories/tips", :locals => {:category => @category}    
  rescue ActiveRecord::RecordNotFound
    render :partial => "/categories/tips", :locals => {:category => nil}    
  end
  
  def require_ownership_or_moderator
    @user ||= User.find(params[:user_id] || params[:id] )
    unless admin? || moderator? || (@user && (@user.eql?(current_user)))
      redirect_to :controller => 'sessions', :action => 'new' and return false
    end
    return @user
  end
  
end