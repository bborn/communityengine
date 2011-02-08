class UserObserver < ActiveRecord::Observer

  def after_create(user)
    UserNotifier.signup_notification(user).deliver
  end

  def after_save(user)
    UserNotifier.activation(user).deliver if user.recently_activated?
  end
end