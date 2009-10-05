class EventsController < BaseController

  require 'htmlentities'
  caches_page :ical
  cache_sweeper :event_sweeper, :only => [:create, :update, :destroy]
 
  #These two methods make it easy to use helpers in the controller.
  #This could be put in application_controller.rb if we want to use
  #helpers in many controllers
  def help
    Helper.instance
  end

  class Helper
    include Singleton
    include ActionView::Helpers::SanitizeHelper
    extend ActionView::Helpers::SanitizeHelper::ClassMethods
  end

  uses_tiny_mce(:options => AppConfig.default_mce_options, :only => [:new, :edit, :create, :update, :clone ])
  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:show])

  before_filter :admin_required, :except => [:index, :show, :ical]

  def ical
    @calendar = RiCal.Calendar
    @calendar.add_x_property 'X-WR-CALNAME', AppConfig.community_name
    @calendar.add_x_property 'X-WR-CALDESC', "#{AppConfig.community_name} #{:events.l}"
    Event.find(:all).each do |ce_event|
      rical_event = RiCal.Event do |event|
        event.dtstart = ce_event.start_time
        event.dtend = ce_event.end_time
        event.summary = ce_event.name + (ce_event.metro_area.blank? ? '' : " (#{ce_event.metro_area})")
        coder = HTMLEntities.new
        event.description = (ce_event.description.blank? ? '' : coder.decode(help.strip_tags(ce_event.description).to_s) + "\n\n") + event_url(ce_event)
        event.location = ce_event.location unless ce_event.location.blank?
      end
      @calendar.add_subcomponent rical_event
    end
    headers['Content-Type'] = "text/calendar; charset=UTF-8"
    render :text => @calendar.export_to, :layout => false
  end

  def show
    @is_admin_user = (current_user && current_user.admin?)
    @event = Event.find(params[:id])
    @comments = @event.comments.find(:all, :limit => 20, :order => 'created_at DESC', :include => :user)
  end

  def index
    @is_admin_user = (current_user && current_user.admin?)
    @events = Event.upcoming.find(:all, :page => {:current => params[:page]})
  end

  def past
    @is_admin_user = (current_user && current_user.admin?)
    @events = Event.past.find(:all, :page => {:current => params[:page]})
    render :template => 'events/index'
  end

  def new
    @event = Event.new(params[:event])
    @metro_areas, @states = setup_metro_area_choices_for(current_user)
    @metro_area_id, @state_id, @country_id = setup_location_for(current_user)
  end
  
  def edit
    @event = Event.find(params[:id])
    @metro_areas, @states = setup_metro_area_choices_for(@event)
    @metro_area_id, @state_id, @country_id = setup_location_for(@event)
  end
    
  def create
    @event = Event.new(params[:event])
    @event.user = current_user
    if params[:metro_area_id]
      @event.metro_area = MetroArea.find(params[:metro_area_id])
    else
      @event.metro_area = nil
    end
    respond_to do |format|
      if @event.save
        flash[:notice] = :event_was_successfully_created.l
        
        format.html { redirect_to event_path(@event) }
      else
        format.html { 
          @metro_areas, @states = setup_metro_area_choices_for(@event)
          if params[:metro_area_id]
            @metro_area_id = params[:metro_area_id].to_i
            @state_id = params[:state_id].to_i
            @country_id = params[:country_id].to_i
          end
          render :action => "new"
        }
      end
    end    
  end

  def update
    @event = Event.find(params[:id])
    if params[:metro_area_id]
      @event.metro_area = MetroArea.find(params[:metro_area_id])
    else
      @event.metro_area = nil
    end
        
    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to event_path(@event) }
      else
        format.html { 
          @metro_areas, @states = setup_metro_area_choices_for(@event)
          if params[:metro_area_id]
            @metro_area_id = params[:metro_area_id].to_i
            @state_id = params[:state_id].to_i
            @country_id = params[:country_id].to_i
          end
          render :action => "edit"
        }
      end
    end
  end
  
  # DELETE /homepage_features/1
  # DELETE /homepage_features/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end

  def clone
    event_to_clone = Event.find(params[:id])
    attributes = event_to_clone.attributes
    attributes.delete('id')
    @event = Event.new(attributes)
    @metro_areas, @states = setup_metro_area_choices_for(@event)
    @metro_area_id, @state_id, @country_id = setup_location_for(@event)
    render :template => 'events/new'
  end

  protected

  def setup_metro_area_choices_for(object)
    metro_areas = states = []
    if object.metro_area
      if object.is_a? Event
        states = object.metro_area.country.states
        if object.metro_area.state
          metro_areas = object.metro_area.state.metro_areas.all(:order=>"name")
        else
          metro_areas = object.metro_area.country.metro_areas.all(:order=>"name")
        end        
      elsif object.is_a? User
        states = object.country.states if object.country
        if object.state
          metro_areas = object.state.metro_areas.all(:order => "name")
        else
          metro_areas = object.country.metro_areas.all(:order => "name")
        end
      end
    end
    return metro_areas, states
  end

  def setup_location_for(object)
    metro_area_id = state_id = country_id = nil
    if object.metro_area
      metro_area_id = object.metro_area_id
      if object.is_a? Event
        state_id = object.metro_area.state_id
        country_id = object.metro_area.country_id
      elsif object.is_a? User
        state_id = object.state_id
        country_id = object.country_id
      end
    end
    return metro_area_id, state_id, country_id
  end

end
