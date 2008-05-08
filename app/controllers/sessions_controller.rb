# This controller handles the login/logout function of the site.  
class SessionsController < BaseController
  if AppConfig.closed_beta_mode
    skip_before_filter :beta_login_required
  end  
  
  def index
    redirect_to :action => "new"
  end  
  
  # render new.rhtml
  def new
    redirect_to user_path(current_user) if current_user
    render :layout => 'beta' if AppConfig.closed_beta_mode
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end

      redirect_back_or_default(dashboard_user_path(current_user))
      flash[:notice] = "Thanks! You're now logged in."
      current_user.track_activity(:logged_in)
    else
      flash[:notice] = "Uh oh. We couldn't log you in with the username and password you entered. Try again?"      
      redirect_to teaser_path and return if AppConfig.closed_beta_mode        
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You've been logged out. Hope you come back soon!"
    redirect_to new_session_path
  end

end
