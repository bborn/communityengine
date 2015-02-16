class PostsController < BaseController
  include Viewable

  cache_sweeper :post_sweeper, :only => [:create, :update, :destroy]
  cache_sweeper :taggable_sweeper, :only => [:create, :update, :destroy]
  caches_action :show, :if => Proc.new{|c| !logged_in? }

  before_action :login_required, :only => [:new, :edit, :update, :destroy, :create, :manage, :preview]
  before_action :find_user, :only => [:new, :edit, :index, :show, :update_views, :manage, :preview]
  before_action :require_ownership_or_moderator, :only => [:edit, :update, :destroy, :create, :manage, :new]

  skip_before_action :verify_authenticity_token, :only => [:update_views, :send_to_friend] #called from ajax on cached pages

  def manage
    Post.unscoped do
      @search = Post.search(params[:q])
      @posts = @search.result
      @posts = @posts.where(:user_id => @user.id).order('created_at DESC').page(params[:page]).per(params[:size]||10)
    end
  end

  def index
    @user = User.find(params[:user_id])
    @category = Category.find_by_name(params[:category_name]) if params[:category_name]

    @posts = @user.posts.recent
    @posts = @post.where('category_id = ?', @category.id) if @category
    @posts = @posts.page(params[:page]).per(10)

    @is_current_user = @user.eql?(current_user)

    @popular_posts = @user.posts.order("view_count DESC").limit(10).to_a

    @rss_title = "#{configatron.community_name}: #{@user.login}'s posts"
    @rss_url = user_posts_path(@user,:format => :rss)

    respond_to do |format|
      format.html # index.rhtml
      format.rss {
        render_rss_feed_for(@posts,
           { :feed => {:title => @rss_title, :link => url_for(:controller => 'posts', :action => 'index', :user_id => @user) },
             :item => {:title => :title,
                       :description => :post,
                       :link => Proc.new {|post| user_post_url(post.user, post)},
                       :pub_date => :published_at} })
      }
    end
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    @post = Post.unscoped.find(params[:id])
    redirect_to user_posts_path(@user), :alert => :post_not_published_yet.l and return false unless @post.is_live? || @post.user.eql?(current_user) || admin? || moderator?

    @rss_title = "#{configatron.community_name}: #{@user.login}'s posts"
    @rss_url = user_posts_path(@user,:format => :rss)

    @user = @post.user
    @is_current_user = @user.eql?(current_user)
    @comment = Comment.new

    @comments = @post.comments.includes(:user).order('created_at DESC').limit(20).to_a

    @previous = @post.previous_post
    @next = @post.next_post
    @popular_posts = @user.posts.except(:order).order('view_count DESC').limit(10).to_a
    @related = Post.find_related_to(@post)
    @most_commented = Post.find_most_commented
  end

  def update_views
    @post = Post.find(params[:id])
    updated = update_view_count(@post)
    render :text => updated ? 'updated' : 'duplicate'
  end

  def preview
    @post = Post.unscoped.find(params[:id])
    redirect_to(:controller => 'sessions', :action => 'new') and return false unless @post.user.eql?(current_user) || admin? || moderator?
  end

  # GET /posts/new
  def new
    @user = User.find(params[:user_id])
    @post = Post.new
    @post.category = Category.find(params[:category_id]) if params[:category_id]
    @post.published_as = 'live'
    @categories = Category.all
  end

  # GET /posts/1;edit
  def edit
    @post = Post.unscoped.find(params[:id])
  end

  # POST /posts
  # POST /posts.xml
  def create
    @user = User.find(params[:user_id])
    @post = Post.new(post_params)
    @post.user = @user

    respond_to do |format|
      if @post.save
        @post.create_poll(params[:poll], params[:choices]) if params[:poll]

        flash[:notice] = @post.category ? :post_created_for_category.l_with_args(:category => @post.category.name.singularize) : :your_post_was_successfully_created.l
        format.html {
          if @post.is_live?
            redirect_to @post.category ? category_path(@post.category) : user_post_path(@user, @post)
          else
            redirect_to manage_user_posts_path(@user)
          end
        }
        format.js
      else
        format.html { render :action => "new" }
        format.js
      end
    end
  end

  # patch /posts/1
  # patch /posts/1.xml
  def update
    @post = Post.unscoped.find(params[:id])
    @user = @post.user

    respond_to do |format|
      if @post.update_attributes(post_params)
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
        flash[:notice] = :your_post_was_deleted.l
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
      flash[:notice] = "Your message has been sent."
      respond_to do |format|
        format.html {render :partial => 'shared/messages'}
        format.js
      end
    else
      flash[:error] = "You entered invalid addresses: "+ @post.invalid_emails.join(', ')+". Please correct these and try again."

      respond_to do |format|
        format.html {render :partial => 'shared/messages', :status => 500}
        format.js
      end
    end
  end


  def popular
    @posts = Post.find_popular({:limit => 15, :since => 3.days})

    @monthly_popular_posts = Post.find_popular({:limit => 20, :since => 30.days})

    @related_tags = ActsAsTaggableOn::Tag.find_by_sql("SELECT tags.id, tags.name, count(*) AS count
      FROM taggings, tags
      WHERE tags.id = taggings.tag_id GROUP BY tags.id, tags.name");

    @rss_title = "#{configatron.community_name} "+:popular_posts.l
    @rss_url = popular_rss_url
    respond_to do |format|
      format.html # index.rhtml
      format.rss {
        render_rss_feed_for(@posts, { :feed => {:title => @rss_title, :link => popular_url},
          :item => {:title => :title, :link => Proc.new {|post| user_post_url(post.user, post)}, :description => :post, :pub_date => :published_at}
          })
      }
    end
  end

  def recent
    @posts = Post.recent.page(params[:page]).per(20)

    @recent_clippings = Clipping.find_recent(:limit => 15)
    @recent_photos = Photo.find_recent(:limit => 10)

    @rss_title = "#{configatron.community_name} "+:recent_posts.l
    @rss_url = recent_rss_url
    respond_to do |format|
      format.html
      format.rss {
        render_rss_feed_for(@posts, { :feed => {:title => @rss_title, :link => recent_url},
          :item => {:title => :title, :link => Proc.new {|post| user_post_url(post.user, post)}, :description => :post, :pub_date => :published_at}
          })
      }
    end
  end

  def featured
    @posts = Post.by_featured_writers.recent.page(params[:page])
    @featured_writers = User.featured

    @rss_title = "#{configatron.community_name} "+:featured_posts.l
    @rss_url = featured_rss_url
    respond_to do |format|
      format.html
      format.rss {
        render_rss_feed_for(@posts, { :feed => {:title => @rss_title, :link => recent_url},
          :item => {:title => :title, :link => Proc.new {|post| user_post_url(post.user, post)}, :description => :post, :pub_date => :published_at}
          })
      }
    end
  end

  def category_tips_update
    return unless request.xhr?
    @category = Category.find(params[:post_category_id] )
    render :partial => "categories/tips", :locals => {:category => @category}
  rescue ActiveRecord::RecordNotFound
    render :partial => "categories/tips", :locals => {:category => nil}
  end

  private

  def require_ownership_or_moderator
    @user ||= User.find(params[:user_id])
    @post ||= Post.unscoped.find(params[:id]) if params[:id]
    unless admin? || moderator? || (@post && (@post.user.eql?(current_user))) || (!@post && @user && @user.eql?(current_user))
      redirect_to :controller => 'sessions', :action => 'new' and return false
    end
    return @user
  end


  def post_params
    params[:post].permit(:category_id, :title, :raw_post, :published_as, :send_comment_notifications, :tag_list)
  end

  def comment_params
    params[:comment].permit(:author_name, :author_email, :notify_by_email, :author_url, :comment)
  end
end
