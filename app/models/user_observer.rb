class UserObserver < ActiveRecord::Observer

  def after_create(user)
    UserNotifier.signup_notification(user)
  end

  def after_save(user)
    UserNotifier.activation(user) if user.recently_activated?
  end
end