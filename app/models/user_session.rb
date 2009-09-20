class UserSession < Authlogic::Session::Base
  remember_me_for 2.weeks
  remember_me false
  after_create :update_user_activity

  private

  def update_user_activity
    controller.session[:last_active] = self.record.sb_last_seen_at
    controller.session[:topics] = controller.session[:forums] = {}
    self.record.update_last_seen_at
  end
end
