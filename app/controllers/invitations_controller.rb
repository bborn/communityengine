class InvitationsController < BaseController
  before_action :login_required

  def index
    @user = current_user
    @invitations = @user.invitations

    respond_to do |format|
      format.html
    end
  end

  def new
    @user = current_user
    @invitation = Invitation.new
  end


  def edit
    @invitation = Invitation.find(params[:id])
  end


  def create
    @user = current_user

    @invitation = Invitation.new(invitation_params)
    @invitation.user = @user

    respond_to do |format|
      if @invitation.save
        flash[:notice] = :invitation_was_successfully_created.l
        format.html {
          unless params[:welcome]
            redirect_to user_path(@invitation.user)
          else
            redirect_to welcome_complete_user_path(@invitation.user)
          end
        }
      else
        format.html { render :action => "new" }
      end
    end
  end

  private

  def invitation_params
    params.require(:invitation).permit(:email_addresses, :message)
  end

end
