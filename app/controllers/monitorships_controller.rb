class MonitorshipsController < BaseController
  before_filter :login_required

  def create
    @monitorship = Monitorship.find_or_initialize_by(:user_id => current_user.id, :topic_id => params[:topic_id])
    @monitorship.update_attribute :active, true
    respond_to do |format| 
      format.html { redirect_to forum_topic_path(params[:forum_id], params[:topic_id]) }
      format.js
    end
  end
  
  def destroy
    Monitorship.where('user_id = ? and topic_id = ?', current_user.id, params[:topic_id]).update_all(['active = ?', false])
    respond_to do |format| 
      format.html { redirect_to forum_topic_path(params[:forum_id], params[:topic_id]) }
      format.js
    end
  end
end
