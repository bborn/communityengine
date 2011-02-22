class AuthorizationsController < BaseController
  before_filter :login_required, :only => [:destroy]

  def create
    omniauth = request.env['omniauth.auth'] #this is where you get all the data from your provider through omniauth
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

    if @authorization.destroy
      flash[:notice] = t('authorizations.destroy.notice', :provider => @authorization.provider.capitalize)      
      redirect_to home_url
    else
      flash[:notice] = @authorization.errors.full_messages.to_sentence
      redirect_to edit_account_user_path(current_user)
    end
  end
end
