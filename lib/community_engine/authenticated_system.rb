module AuthenticatedSystem
  def update_last_seen_at
     return unless logged_in?
     User.update_all ['sb_last_seen_at = ?', Time.now.utc], ['id = ?', current_user.id] 
     current_user.sb_last_seen_at = Time.now.utc
  end
  
  def login_by_token
  end
      
  protected
    # Returns true or false if the user is logged in.
    def logged_in?
      current_user ? true : false
    end
    
    # Accesses the current user from the session.
    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end

    # Create a user session without credentials.
    def current_user=(user)
      return if current_user # Use act_as_user= to switch to another user account
      UserSession.create(user, true)
    end

    # Set session to another user.  Only available to admins
    def assume_user(new_user)
      return unless current_user && current_user.admin? && !new_user.admin?
      session[:admin_id] = current_user.id
      UserSession.create(new_user, true)
    end

    def return_to_admin
      unless current_user && !session[:admin_id].nil? && !current_user.admin?
        redirect_to login_path
        return
      end

      admin = User.find(session[:admin_id])
      if admin && admin.admin?
        session[:admin_id] = nil
        UserSession.create(admin, true)
        redirect_to user_path(admin)
      else
        current_user_session.destroy
        redirect_to login_path
      end
    end

    # Accesses the current session.
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    # Check if the user is authorized.
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorize?
    #    current_user.login != "bob"
    #  end
    def authorized?
      true
    end
    def admin?
     logged_in? && current_user.admin?
    end
    def moderator?
     logged_in? && current_user.moderator?      
    end
    
    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |accepts|
        accepts.html do
          store_location
          redirect_to login_path and return false
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "Couldn't authenticate you", :status => '401 Unauthorized'
        end
        accepts.js do
          store_location 
          render :update do |page|
            page.redirect_to login_path
          end and return false
        end        
      end
      false
    end
    
    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :current_user_session, :logged_in?, :admin?, :moderator?
    end

    private

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      store_location
      logged_in? && authorized? ? true : access_denied
    end

    def require_user
      unless current_user
        store_location
        access_denied
      end
    end

    def require_no_user
      if current_user
        store_location
        access_denied
        return false
      end
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.url
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

end
