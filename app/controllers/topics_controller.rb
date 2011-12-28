class TopicsController < BaseController
  before_filter :find_forum_and_topic, :except => :index
  before_filter :login_required, :except => [:index, :show]

  uses_tiny_mce do
    {:only => [:show, :new, :create, :update], :options => configatron.default_mce_options}
  end

  def index
    @forum = Forum.find(params[:forum_id])    
    respond_to do |format|
      format.html { redirect_to forum_path(params[:forum_id]) }
      format.xml do
        @topics = @forum.topics.find(:all, :order => 'sticky desc, replied_at desc', :limit => 25)
        render :xml => @topics.to_xml
      end
    end
  end

  def new
    @topic = Topic.new(params[:topic])
    @topic.body = params[:topic][:body] if params[:topic] 
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
        render :action => 'show.xml.builder', :layout => false
      end
    end
  end
  
  def create
    # this is icky - move the topic/first post workings into the topic model?
    Topic.transaction do
      @topic  = @forum.topics.new(params[:topic])
      assign_protected
      @post   = @topic.sb_posts.new(params[:topic])
      @post.topic=@topic
      @post.user = current_user
      # only save topic if post is valid so in the view topic will be a new record if there was an error
      @topic.tag_list = params[:tag_list] || ''
      @topic.save if @post.valid?
      @post.save
    end
    if !@topic.valid?
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
  
  def update
    @topic.attributes = params[:topic]
    assign_protected
    @topic.tag_list = params[:tag_list] || ''
    @topic.save!
    respond_to do |format|
      format.html { redirect_to forum_topic_path(@forum, @topic) }
      format.xml  { head 200 }
    end
  end
  
  def destroy
    @topic.destroy
    flash[:notice] = :topic_deleted.l_with_args(:topic => CGI::escapeHTML(@topic.title)) 
    respond_to do |format|
      format.html { redirect_to forum_path(@forum) }
      format.xml  { head 200 }
    end
  end
  
  protected
    def assign_protected
      @topic.user     = current_user if @topic.new_record?
      # admins and moderators can sticky and lock topics
      return unless admin? or current_user.moderator_of?(@topic.forum)
      @topic.sticky, @topic.locked = params[:topic][:sticky], params[:topic][:locked] 
      # only admins can move
      return unless admin?
      @topic.forum_id = params[:topic][:forum_id] if params[:topic][:forum_id]
    end
    
    def find_forum_and_topic
      @forum = Forum.find(params[:forum_id])
      @topic = @forum.topics.find(params[:id]) if params[:id]
    end

    #overide in your app
    def authorized?
      %w(new create).include?(action_name) || @topic.editable_by?(current_user)
    end
end
