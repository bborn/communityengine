class SbPostsController < BaseController
  before_filter :find_post,      :except => [:index, :monitored, :search, :new, :create]
  before_filter :login_required, :except => [:index, :search, :show, :monitored, :create]

  before_filter :only => [:create] do |controller|
    login_required unless configatron.allow_anonymous_forum_posting
  end

  skip_before_filter :verify_authenticity_token, :only => [:create] #remove for the create action
  before_filter do |controller|
    #add it back unless anonymous posting is allowed
    verify_authenticity_token if controller.action_name.eql?('create') && !configatron.allow_anonymous_forum_posting
  end

  uses_tiny_mce do
    {:only => [:edit, :update], :options => configatron.default_mce_options}
  end


  def index
    conditions = []
    [:user_id, :forum_id].each { |attr| 
      conditions << SbPost.send(:sanitize_sql, ["sb_posts.#{attr} = ?", params[attr].to_i]) if params[attr] 
    }
    conditions = conditions.any? ? conditions.collect { |c| "(#{c})" }.join(' AND ') : nil

    @posts = SbPost.with_query_options.where(conditions).page(params[:page])
    
    @users = User.find(:all, :select => 'distinct *', :conditions => ['id in (?)', @posts.collect(&:user_id).uniq]).index_by(&:id)
    render_posts_or_xml
  end

  def search
    conditions = params[:q].blank? ? nil : SbPost.send(:sanitize_sql, ['LOWER(sb_posts.body) LIKE ?', "%#{params[:q]}%"])
    
    @posts = SbPost.with_query_options.where(conditions).page(params[:page])

    @users = User.find(:all, :select => 'distinct *', :conditions => ['id in (?)', @posts.collect(&:user_id).uniq]).index_by(&:id)
    render_posts_or_xml :index
  end

  def monitored
    @user = User.find params[:user_id]    
    @posts = SbPost.with_query_options.joins('INNER JOIN monitorships ON monitorships.topic_id = topics.id').where('monitorships.user_id = ? AND sb_posts.user_id != ?', params[:user_id], @user.id).page(params[:page])
    render_posts_or_xml
  end

  def show
    respond_to do |format|
      format.html { redirect_to forum_topic_path(@post.forum_id, @post.topic_id) }
      format.xml  { render :xml => @post.to_xml }
    end
  end

  def new
    if logged_in?
      redirect_to forum_topic_path(:forum_id => params[:forum_id], :id => params[:topic_id], :anchor => 'reply-form', :page => params[:page] || '1') and return
    end
  end

  def create
    @topic = Topic.find_by_id_and_forum_id(params[:topic_id].to_i, params[:forum_id].to_i, :include => :forum)
    if @topic.locked?
      respond_to do |format|
        format.html do
          flash[:notice] = :this_topic_is_locked.l
          redirect_to(forum_topic_path(:forum_id => params[:forum_id], :id => params[:topic_id]))
        end
      end
      return
    end

    @forum = @topic.forum
    @post  = @topic.sb_posts.new(params[:post])

    @post.user = current_user if current_user
    @post.author_ip = request.remote_ip #save the ip address for everyone, just because    

    if (logged_in? || verify_recaptcha(@post)) && @post.save
      respond_to do |format|
        format.html do
          redirect_to forum_topic_path(:forum_id => params[:forum_id], :id => params[:topic_id], :anchor => @post.dom_id, :page => params[:page] || '1')
        end
        format.js
      end
    else
      flash.now[:notice] = @post.errors.full_messages.to_sentence
      respond_to do |format|
        format.html do
          redirect_to forum_topic_path({:forum_id => params[:forum_id], :id => params[:topic_id], :anchor => 'reply-form', :page => (params[:page] || '1')}.merge({:post => params[:post]}))
        end
        format.js
      end
    end
  end
  
  def edit
    respond_to do |format| 
      format.html 
      format.js
    end
  end
  
  def update
    @post.attributes = params[:post]
    @post.save!
  rescue ActiveRecord::RecordInvalid
    flash[:bad_reply] = :an_error_occurred.l
  ensure
    respond_to do |format|
      format.html do
        redirect_to forum_topic_path(:forum_id => params[:forum_id], :id => params[:topic_id], :anchor => @post.dom_id, :page => params[:page] || '1')
      end
      format.js
      format.xml { head 200 }
    end
  end

  def destroy
    @post.destroy
    flash[:notice] = :sb_post_was_deleted.l_with_args(:title => CGI::escapeHTML(@post.topic.title))
    # check for posts_count == 1 because its cached and counting the currently deleted post
    @post.topic.destroy and redirect_to forum_path(params[:forum_id]) if @post.topic.sb_posts_count == 1
    respond_to do |format|
      format.html do
        redirect_to forum_topic_path(:forum_id => params[:forum_id], :id => params[:topic_id], :page => params[:page]) unless performed?
      end
      format.xml { head 200 }
    end
  end

  protected
    #overide in your app
    def authorized?
      %w(create new).include?(action_name) || @post.editable_by?(current_user)
    end
    
    def find_post
      @post = SbPost.find_by_id_and_topic_id_and_forum_id(params[:id].to_i, params[:topic_id].to_i, params[:forum_id].to_i) || raise(ActiveRecord::RecordNotFound)
    end
    
    def render_posts_or_xml(template_name = action_name)
      respond_to do |format|
        format.html { render :action => "#{template_name}" }
        format.rss  { render :action => "#{template_name}.xml.builder", :layout => false }
        format.xml  { render :xml => @posts.to_xml }
      end
    end
end
