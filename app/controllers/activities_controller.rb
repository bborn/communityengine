class ActivitiesController < BaseController
  before_filter :login_required
  before_filter :find_user
  before_filter :require_current_user
  
  def network
    @activities = @user.network_activity(:size => 15, :current => params[:page])
  end

end
