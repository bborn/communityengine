class ModeratorsController < BaseController
  before_filter :login_required
  
  def create
    @forum = Forum.find(params[:forum_id])
    @user = User.find(params[:user_id])
    @moderatorship = Moderatorship.create!(:forum => @forum, :user => @user)
  end

  def destroy
    @moderatorship = Moderatorship.find(params[:id])
    @moderatorship.destroy
  end

  #overide in your app
  def authorized?
    current_user.admin?
  end
end
