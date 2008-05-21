class CommentsController < BaseController
  before_filter :login_required, :except => [:index]
  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:index])

  cache_sweeper :comment_sweeper, :only => [:create, :destroy]

  def show
    @comment = Comment.find(params[:id])
    render :text => @comment.inspect
  end

  def index
    @commentable = Inflector.constantize(Inflector.camelize(params[:commentable_type])).find(params[:commentable_id])

    unless logged_in? || @commentable && @commentable.owner.profile_public?
      flash.now[:error] = "This user's profile is not public. You'll need to create an account and log in to access it."
      redirect_to :controller => 'sessions', :action => 'new' and return
    end

    if @commentable
      @comments_count = @commentable.comments.count
      @pages = Paginator.new self, @comments_count, 10, (params[:page] || 1)
      @comments = @commentable.comments.find(:all,
          :limit  =>  @pages.items_per_page,
          :offset =>  @pages.current.offset,
          :order => 'created_at DESC'
        )
                
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
        flash[:notice] = "Sorry, we couldn't find any comments for that #{Inflector.constantize(Inflector.camelize(params[:commentable_type]))}"
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
    @comment.user_id = current_user.id
    
    respond_to do |format|
      if @comment.save
        @commentable.add_comment @comment
        UserNotifier.deliver_comment_notice(@comment) if should_receive_notification(@comment)
        deliver_comment_notice_to_previous_commenters(@comment)        
                
        flash.now[:notice] = 'Comment was successfully created.'        
        format.html { redirect_to :controller => Inflector.underscore(params[:commentable_type]).pluralize, :action => 'show', :id => params[:commentable_id], :user_id => @comment.recipient.id }
        format.js {
          render :partial => 'comments/comment.html.haml', :locals => {:comment => @comment, :highlighted => true}
        }
      else
        flash.now[:error] = "Your comment couldn't be saved. #{@comment.errors.full_messages.join(", ")}"
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
      flash.now[:notice] = "The comment was deleted."
    else
      flash.now[:error] = "Comment could not be deleted."
    end
    respond_to do |format|
      format.html { redirect_to users_url }
      format.js   { 
        render :inline => flash[:error], :status => 500 if flash[:error]
        render :nothing => true if flash[:notice]
      }
    end    
  end
  
  protected
  
  def deliver_comment_notice_to_previous_commenters(comment)
    comment.previous_commenters_to_notify.each do |user|
        UserNotifier.deliver_follow_up_comment_notice(user, comment)
    end
  end  
  
  def should_receive_notification(comment)
    return false if comment.recipient.eql?(@comment.user)
    return false unless comment.recipient.notify_comments?
    true
  end

end