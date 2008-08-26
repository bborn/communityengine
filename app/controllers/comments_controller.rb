class CommentsController < BaseController
  before_filter :login_required, :except => [:index]
  if AppConfig.allow_anonymous_commenting
    skip_before_filter :login_required, :only => [:create]
  end
  
  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:index])

  cache_sweeper :comment_sweeper, :only => [:create, :destroy]

  def show
    @comment = Comment.find(params[:id])
    render :text => @comment.inspect
  end

  def index
    @commentable = Inflector.constantize(Inflector.camelize(params[:commentable_type])).find(params[:commentable_id])

    unless logged_in? || @commentable && @commentable.owner.profile_public?
      flash.now[:error] = "This user's profile is not public. You'll need to create an account and log in to access it.".l
      redirect_to :controller => 'sessions', :action => 'new' and return
    end

    if @commentable
      @comments_count = @commentable.comments.count        
      @comments = Comment.recent.find(:all, :page => {:size => 10, :current => params[:page], :count => @comments_count})
                
      unless @comments.empty?        
        @title = @comments.first.commentable_name
        @rss_title = "#{AppConfig.community_name}: Comments - #{@title}"
        @rss_url = formatted_comments_path(Inflector.underscore(@commentable.class),@commentable.id, :rss)

        respond_to do |format|        
          format.html {
            @user = @comments.first.recipient        
            render :action => 'index' and return            
          }
          format.rss {
            @rss_title = "#{AppConfig.community_name}: #{Inflector.underscore(@commentable.class).capitalize} Comments - #{@title}"
            @rss_url = comments_url(Inflector.underscore(@commentable.class), @commentable.to_param)
            render_rss_feed_for(@comments,
               { :feed => {:title => @title},
                 :item => {:title => :title_for_rss,
                           :description => :comment,
                           :link => :generate_commentable_url,
                           :pub_date => :created_at} }) and return
            
          }
        end
      end
    end
    
    
    respond_to do |format|        
      format.html {
        flash[:notice] = :no_comments_found.l_with_args(type => Inflector.constantize(Inflector.camelize(params[:commentable_type])))
        redirect_to :controller => 'base', :action => 'site_index' and return      
      }
      format.rss {
        @rss_title = "#{AppConfig.community_name}: #{Inflector.underscore(@commentable.class).capitalize} Comments - #{@title}"
        @rss_url = comments_url(Inflector.underscore(@commentable.class), @commentable.to_param)
        render_rss_feed_for(@comments,
           { :feed => {:title => @title},
             :item => {:title => :title_for_rss,
                       :description => :comment,
                       :link => :generate_commentable_url,
                       :pub_date => :created_at} }) and return
      
      }
    end
  end

  def new
    @commentable = Inflector.constantize(Inflector.camelize(params[:commentable_type])).find(params[:commentable_id])    
    redirect_to "#{url_for(:controller => Inflector.underscore(params[:commentable_type]).pluralize, :action => 'show', :id => params[:commentable_id], :user_id => @commentable.owner.to_param)}#comments"
  end


  def create
    @commentable = Inflector.constantize(Inflector.camelize(params[:commentable_type])).find(params[:commentable_id])
    @comment = Comment.new(params[:comment])
    @comment.recipient = @commentable.owner
    
    @comment.user_id = current_user.id if current_user
    @comment.author_ip = request.remote_ip #save the ip address for everyone, just because
    
    respond_to do |format|
      if (logged_in? || verify_recaptcha(@comment)) && @comment.save
        @commentable.add_comment @comment
        UserNotifier.deliver_comment_notice(@comment) if @comment.should_notify_recipient?
        @comment.notify_previous_commenters
                
        flash.now[:notice] = 'Comment was successfully created.'.l        
        format.html { redirect_to :controller => Inflector.underscore(params[:commentable_type]).pluralize, :action => 'show', :id => params[:commentable_id], :user_id => @comment.recipient.id }
        format.js {
          render :partial => 'comments/comment.html.haml', :locals => {:comment => @comment, :highlighted => true}
        }
      else
        flash.now[:error] = :comment_save_error.l_with_args(:error => @comment.errors.full_messages.to_sentence)
        format.html { redirect_to :controller => Inflector.underscore(params[:commentable_type]).pluralize, :action => 'show', :id => params[:commentable_id] }
        format.js{
          render :inline => flash[:error], :status => 500
        }
      end
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    if @comment.can_be_deleted_by(current_user)
      @comment.destroy
      flash.now[:notice] = "The comment was deleted.".l
    else
      flash.now[:error] = "Comment could not be deleted.".l
    end
    respond_to do |format|
      format.html { redirect_to users_url }
      format.js   { 
        render :inline => flash[:error], :status => 500 if flash[:error]
        render :nothing => true if flash[:notice]
      }
    end    
  end
  

end