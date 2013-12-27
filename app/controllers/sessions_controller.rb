# This controller handles the login/logout function of the site.
class SessionsController < BaseController

  skip_before_filter :store_location, :only => [:new, :create]

  def index
    redirect_to :action => "new"
  end

  def new
    redirect_to user_path(current_user) and return if current_user
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(:login => params[:email], :password => params[:password], :remember_me => params[:remember_me])

    if @user_session.save
      self.current_user = @user_session.record #if current_user has been called before this, it will ne nil, so we have to make to reset it

      flash[:notice] = :thanks_youre_now_logged_in.l
      redirect_back_or_default(dashboard_user_path(current_user))
    else
      flash[:notice] = :uh_oh_we_couldnt_log_you_in_with_the_username_and_password_you_entered_try_again.l
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    reset_session
    flash[:notice] = :youve_been_logged_out_hope_you_come_back_soon.l
    redirect_to new_session_path
  end

end
