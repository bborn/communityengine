class AuthorizationsController < BaseController
  before_filter :require_user, :only => [:destroy]

  def create
    omniauth = request.env['rack.auth'] #this is where you get all the data from your provider through omniauth
    @auth = Authorization.find_from_hash(omniauth)
    provider_name = omniauth['provider'].capitalize
    if current_user
      flash[:notice] = t('authorizations.create.success_existing_user', :provider => provider_name)
      current_user.authorizations.create(:provider => omniauth['provider'], :uid => omniauth['uid']) #Add an auth to existing user
    elsif @auth
      flash[:notice] = t('authorizations.create.welcome_back_message', :provider => provider_name)
      UserSession.create(@auth.user, true) #User is present. Login the user with his social account
    else  
      @new_auth = Authorization.create_from_hash(omniauth, current_user) #Create a new user
      flash[:notice] = t('authorizations.create.success_new_user', :provider => provider_name)
      UserSession.create(@new_auth.user, true) #Log the authorizing user in.
    end
    redirect_to home_url
  end
  
  def failure
    flash[:notice] = t('authorizations.failure.notice')
    redirect_to home_url
  end
  
  def destroy
    @authorization = current_user.authorizations.find(params[:id])
    flash[:notice] = t('authorizations.destroy.notice', :provider => @authorization.provider.capitalize)
    @authorization.destroy
    redirect_to home_url
  end
end
