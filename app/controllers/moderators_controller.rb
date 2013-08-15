class ModeratorsController < BaseController
  before_filter :admin_required
  
  def create
    @forum = Forum.find(params[:forum_id])
    @user = User.friendly.find(params[:user_id])
    @moderatorship = Moderatorship.create!(:forum => @forum, :user => @user)
    respond_to do |format|
      format.js
    end

  end

  def destroy
    @moderatorship = Moderatorship.find(params[:id])
    @moderatorship.destroy
    respond_to do |format|
      format.js
    end
  end


end
