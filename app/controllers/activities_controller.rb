class ActivitiesController < BaseController
  before_filter :login_required,  :except => :index
  before_filter :find_user,       :except => [:index, :destroy]
  before_filter :require_current_user,            :except => [:index, :destroy]
  before_filter :require_ownership_or_moderator,  :only   => [:destroy]  
  
  
  def network
    @activities = @user.network_activity(:size => 15, :current => params[:page])
  end
  
  def index
    @activities = User.recent_activity(:size => 30, :current => params[:page], :limit => 1000)
    @popular_tags = popular_tags(30, ' count DESC')    
  end
  
  def destroy
    @activity = Activity.find(params[:id])
    @activity.destroy
    
    respond_to do |format|
      format.html {redirect_to :back and return}
      format.js
    end
  end
  
  private
    def require_ownership_or_moderator
      @activity = Activity.find(params[:id])  
         
      unless @activity && @activity.can_be_deleted_by?(current_user)
        redirect_to :controller => 'sessions', :action => 'new' and return false
      end
      return @user
    end

end
