class TopicsController < BaseController
  before_action :find_forum_and_topic, :except => :index
  before_action :login_required, :except => [:index, :show]
  after_action  :verify_authorized, :except => [:index, :show]


  def index
    @forum = Forum.find(params[:forum_id])
    respond_to do |format|
      format.html { redirect_to forum_path(params[:forum_id]) }
      format.xml do
        @topics = @forum.topics.order('sticky desc, replied_at desc').limit(25)
        render :xml => @topics.to_xml
      end
    end
  end

  def new
    @topic = Topic.new
    @topic.sb_posts.build
    authorize @topic
  end

  def show
    respond_to do |format|
      format.html do
        # see notes in base_controller.rb on how this works
        current_user.update_last_seen_at if logged_in?
        # keep track of when we last viewed this topic for activity indicators
        (session[:topics] ||= {})[@topic.id] = Time.now.utc if logged_in?
        # authors of topics don't get counted towards total hits
        @topic.hit! unless logged_in? and @topic.user == current_user

        @posts = @topic.sb_posts.recent.includes(:user).page(params[:page]).per(25)

        @voices = @posts.map(&:user).compact.uniq
        @post   = SbPost.new(params[:post])
      end
      format.xml do
        render :xml => @topic.to_xml
      end
      format.rss do
        @posts = @topic.sb_posts.recent.limit(25)
        render :action => 'show', :layout => false, :formats => [:xml]
      end
    end
  end

  def create
    @topic = @forum.topics.new(topic_params)
    authorize @topic

    assign_protected

    @post = @topic.sb_posts.first
    if (!@post.nil?)
      @post.user = current_user
    end

    @topic.tag_list = params[:tag_list] || ''

    if !@topic.save
      respond_to do |format|
        format.html {
          render :action => 'new' and return
        }
      end
    else
      respond_to do |format|
        format.html {
          redirect_to forum_topic_path(@forum, @topic)
        }
        format.xml  {
          head :created, :location => forum_topic_url(:forum_id => @forum, :id => @topic, :format => :xml)
        }
      end
    end
  end

  def edit
    authorize @topic
  end

  def update
    assign_protected

    authorize @topic
    @topic.tag_list = params[:tag_list] || ''
    @topic.update_attributes!(topic_params)
    respond_to do |format|
      format.html { redirect_to forum_topic_path(@forum, @topic) }
      format.xml  { head 200 }
    end
  end

  def destroy
    authorize @topic

    @topic.destroy
    flash[:notice] = :topic_deleted.l_with_args(:topic => CGI::escapeHTML(@topic.title))
    respond_to do |format|
      format.html { redirect_to forum_path(@forum) }
      format.xml  { head 200 }
    end
  end

  protected
    def assign_protected
      @topic.sticky = @topic.locked = 0
      @topic.forum_id = @forum.id
      @topic.user = current_user if @topic.new_record?

      # admins and moderators can sticky and lock topics
      return unless admin? or current_user.moderator_of?(@topic.forum)
      @topic.sticky, @topic.locked = topic_params[:sticky], topic_params[:locked]
      # only admins can move
      return unless admin?
      @topic.forum_id = topic_params[:forum_id] if topic_params[:forum_id]
    end

    def find_forum_and_topic
      @forum = Forum.find(params[:forum_id])
      @topic = @forum.topics.find(params[:id]) if params[:id]
    end


  def topic_params
    params[:topic].permit(:tag_list, :title, :sticky, :locked, {:sb_posts_attributes => [:body]}, :forum_id)
  end
end
