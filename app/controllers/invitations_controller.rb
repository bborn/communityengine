class InvitationsController < BaseController
  before_filter :login_required

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

    @invitation = Invitation.new(params[:invitation])
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
  
end