class RsvpsController < BaseController

  before_filter :login_required, :only => [:new, :edit, :update, :destroy, :create]
  before_filter :find_event
  before_filter :require_ownership_or_moderator, :only => [:edit, :update, :destroy]

  def find_event
    @event = Event.find(params[:event_id])
  rescue
    redirect_to events_url
  end

  # GET /rsvps/new
  def new
    @rsvp = @event.rsvps.new
  end

  # GET /posts/1;edit
  def edit
  end

  # POST /rsvps
  # POST /rsvps.xml
  def create
    @rsvp = @event.rsvps.new(rsvp_params)
    @rsvp.user = current_user
    respond_to do |format|
      if @rsvp.save
        flash[:notice] = :your_rsvp_was_successfully_created.l
        format.html { redirect_to [@event] }
        format.js
      else
        format.html { render :action => "new" }
        format.js        
      end
    end
  end
  
  # patch /rsvps/1
  # patch /rsvps/1.xml
  def update
    @rsvp.attendees_count = rsvp_params[:attendees_count]
    respond_to do |format|
      if @rsvp.save
        flash[:notice] = :your_rsvp_was_successfully_updated.l
        format.html { redirect_to [@event] }
      else
        format.html { render :action => "edit" }  
      end
    end
  end
  
  # DELETE /rsvps/1
  # DELETE /rsvps/1.xml
  def destroy
    @rsvp.destroy
    respond_to do |format|
      format.html { 
        flash[:notice] = :your_rsvp_has_been_retracted.l
        redirect_to [@event]   
        }
    end
  end
 
  private
  
  def require_ownership_or_moderator
    @rsvp = @event.rsvps.find(params[:id])
    @user = @rsvp.user
    unless admin? || moderator? || (@rsvp && (@user.eql?(current_user)))
      redirect_to [@event] and return false
    end
  rescue
    redirect_to [@event]
  end

  def rsvp_params
    params[:rsvp].permit(:attendees_count)
  end
  
end
