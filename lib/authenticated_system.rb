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
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      (@current_user ||= session[:user] ? User.find_by_id(session[:user]) : :false).is_a?(User)
    end
    
    # Accesses the current user from the session.
    def current_user
      @current_user if logged_in?
    end
    
    # Store the given user in the session.
    def current_user=(new_user)
      unless new_user.nil?
        if @current_user and !@current_user.eql?(:false) and @current_user.admin? and !new_user.admin?
          session[:admin_id] = @current_user.id
        elsif !session[:admin_id].nil? && !@current_user.admin? && new_user.admin?
          session[:admin_id] = nil
        end
      else
        session[:admin_id] = nil
      end

      session[:user] = (new_user.nil? || new_user.is_a?(Symbol)) ? nil : new_user.id
      @current_user = new_user
      if current_user
        # this is used while we're logged in to know which threads are new, etc        
        session[:last_active] = current_user.sb_last_seen_at
        session[:topics] = session[:forums] = {}
        update_last_seen_at        
      end
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
      username, passwd = get_auth_data
      self.current_user ||= User.authenticate(username, passwd) || :false if username && passwd
      logged_in? && authorized? ? true : access_denied
    end
    
    def beta_login_required
      login_required
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
          redirect_to(:controller => '/sessions', :action => 'new') and return false
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "Could't authenticate you", :status => '401 Unauthorized'
        end
      end
      false
    end  
    
    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end
    
    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      session[:return_to] ? redirect_to(session[:return_to]) : redirect_to(default)
      session[:return_to] = nil
    end
    
    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?, :admin?
    end

    # When called with before_filter :login_from_cookie will check for an :auth_token
    # cookie and log the user back in if apropriate
    def login_from_cookie
      return unless cookies[:auth_token] && !logged_in?
      user = User.find_by_remember_token(cookies[:auth_token])
      if user && user.remember_token?
        user.remember_me
        self.current_user = user
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        flash[:notice] = "Logged in successfully"
      end
    end

  private
    # gets BASIC auth info
    def get_auth_data
      user, pass = nil, nil
      # extract authorisation credentials 
      if request.env.has_key? 'X-HTTP_AUTHORIZATION' 
        # try to get it where mod_rewrite might have put it 
        authdata = request.env['X-HTTP_AUTHORIZATION'].to_s.split 
      elsif request.env.has_key? 'HTTP_AUTHORIZATION' 
        # this is the regular location 
        authdata = request.env['HTTP_AUTHORIZATION'].to_s.split  
      end 
       
      # at the moment we only support basic authentication 
      if authdata && authdata[0] == 'Basic' 
        user, pass = Base64.decode64(authdata[1]).split(':')[0..1] 
      end 
      return [user, pass] 
    end
end
