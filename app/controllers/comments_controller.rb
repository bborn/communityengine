class CommentsController < BaseController
  before_filter :login_required, :except => [:index, :unsubscribe]
  before_filter :admin_or_moderator_required, :only => [:delete_selected, :edit, :update]

  if configatron.allow_anonymous_commenting
    skip_before_filter :verify_authenticity_token, :only => [:create]   #because the auth token might be cached anyway
    skip_before_filter :login_required, :only => [:create]
  end

  uses_tiny_mce do
    {:only => [:index, :edit, :update], :options => configatron.simple_mce_options}
  end

  cache_sweeper :comment_sweeper, :only => [:create, :destroy]
  
  def edit
    @comment = Comment.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def update
    @comment = Comment.find(params[:id])
    @comment.update_attributes!(params[:comment])   
  rescue ActiveRecord::RecordInvalid
    flash[:error] = :an_error_occurred.l
  ensure 
    respond_to do |format|
      format.js
    end    
  end


  def index
    commentable_type = get_commentable_type(params[:commentable_type])
    commentable_class = commentable_type.singularize.constantize
    commentable_type_humanized = commentable_type.humanize
    commentable_type_tableized = commentable_type.tableize
    
    if @commentable = commentable_class.find(params[:commentable_id])
      unless logged_in? || (@commentable.owner && @commentable.owner.profile_public?)
        flash.now[:error] = :private_user_profile_message.l
        redirect_to login_path and return
      end
      
      @comments = @commentable.comments.recent.page(params[:page])
      @title = commentable_type_humanized            
      @rss_url = commentable_comments_url(commentable_type_tableized, @commentable, :format => :rss)

      if @comments.any?
        first_comment = @comments.first
        @user = first_comment.recipient
        @title = first_comment.commentable_name
        @back_url = commentable_url(first_comment)
        respond_to do |format|
          @rss_title = "#{configatron.community_name}: #{commentable_type_humanized} Comments - #{@title}"                
          format.html
          format.rss {
            render_comments_rss_feed_for(@comments, @commentable, @rss_title) and return
          }
        end              
      else
        if @commentable.is_a?(User)
          @user = @commentable
          @title = @user.login
          @back_url = user_path(@user)
        elsif @user = @commentable.user
          @title = @commentable.respond_to?(:title) ? @commentable.title : @title
          @back_url = url_for([@user, @commentable])
        end
        
        respond_to do |format|
          format.html
          format.rss {
            @rss_title = "#{configatron.community_name}: #{commentable_type_humanized} Comments - #{@title}"                            
            render_comments_rss_feed_for([], @commentable, @rss_title) and return
          }
        end        
      end   
    else
      flash[:notice] = :no_comments_found.l_with_args(:type => commentable_type_humanized)
      redirect_to home_path
    end          
  end

  def new
    @commentable = get_commentable_type(params[:commentable_type]).constantize.find(params[:commentable_id])
    redirect_to commentable_comments_url(@commentable.class.to_s.tableize, @commentable.id)
  end


  def create
    commentable_type = get_commentable_type(params[:commentable_type])
    @commentable = commentable_type.singularize.constantize.find(params[:commentable_id])

    @comment = Comment.new(params[:comment])

    @comment.commentable = @commentable
    @comment.recipient = @commentable.owner
    @comment.user_id = current_user.id if current_user
    @comment.author_ip = request.remote_ip #save the ip address for everyone, just because

    respond_to do |format|
      if (logged_in? || verify_recaptcha(@comment)) && @comment.save
        @comment.send_notifications

        flash.now[:notice] = :comment_was_successfully_created.l
        format.html { redirect_to commentable_url(@comment) }
        format.js
      else
        flash.now[:error] = :comment_save_error.l_with_args(:error => @comment.errors.full_messages.to_sentence)
        format.html { redirect_to commentable_comments_path(commentable_type.tableize, @commentable) }
        format.js
      end
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    if @comment.can_be_deleted_by(current_user) && @comment.destroy
      if params[:spam] && !configatron.akismet_key.nil?
        @comment.spam!
      end
      flash.now[:notice] = :the_comment_was_deleted.l
    else
      flash.now[:error] = :comment_could_not_be_deleted.l
    end
    respond_to do |format|
      format.html { redirect_to users_url }
      format.js
    end
  end
  
  def delete_selected
    if request.post?
      if params[:delete]
        params[:delete].each { |id|
          comment = Comment.find(id)
          comment.spam! if params[:spam] && !configatron.akismet_key.nil?
          comment.destroy if comment.can_be_deleted_by(current_user)
        }
      end
      flash[:notice] = :comments_deleted.l                
      redirect_to admin_comments_path
    end
  end  

  
  def unsubscribe
    @comment = Comment.find(params[:id])
    if @comment.token_for(params[:email]).eql?(params[:token])
      @comment.unsubscribe_notifications(params[:email])
      flash[:notice] = :comment_unsubscribe_succeeded.l
    end
    redirect_to commentable_url(@comment)
  end


  private
    
    def get_commentable_type(string)
      string.camelize
    end
        
    def render_comments_rss_feed_for(comments, commentable, title)
      render_rss_feed_for(comments,
        { :class => commentable.class,
          :feed => {  :title => title,
                      :link => commentable_comments_url(commentable.class.to_s.tableize, commentable) },
          :item => { :title => :title_for_rss,
                     :description => :comment,
                     :link => Proc.new {|comment| commentable_url(comment)},
                     :pub_date => :created_at
                     }
        })
    end
  
end
