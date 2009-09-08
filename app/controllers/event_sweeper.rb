class EventSweeper < ActionController::Caching::Sweeper
  observe Event # This sweeper is going to keep an eye on the Event model

  # If our sweeper detects that an Event was created call this
  def after_create(event)
    expire_cache_for(event)
  end
  
  # If our sweeper detects that an Event was updated call this
  def after_update(event)
    expire_cache_for(event)
  end
  
  # If our sweeper detects that an Event was deleted call this
  def after_destroy(event)
    expire_cache_for(event)
  end
          
  private
  def expire_cache_for(record)
    # Expire the ical page
    expire_page(:controller => 'events', :action => 'ical', :format => 'ics')
  end
end
