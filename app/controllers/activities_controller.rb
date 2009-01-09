class ActivitiesController < BaseController
  before_filter :login_required, :except => :index
  before_filter :find_user, :except => :index
  before_filter :require_current_user, :except => :index
  
  def network
    @activities = @user.network_activity(:size => 15, :current => params[:page])
  end
  
  def index
    @activities = User.recent_activity(:size => 30, :current => params[:page], :limit => 1000)
    @popular_tags = popular_tags(30, ' count DESC')    
  end

end
