require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase
  
  fixtures :events

  def test_should_be_invalid_without_name
    assert_no_difference Event, :count do
      u = Event.new(valid_event_attributes.except(:name))
      u.save
      assert u.errors.on(:name)
    end    
  end

  def test_should_be_invalid_without_date
    assert_no_difference Event, :count do
      u = Event.new(valid_event_attributes.except(:start_time))
      u.save
      assert u.errors.on(:start_time)
    end    
  end
  
  def test_should_be_invalid_without_name
    assert_no_difference Event, :count do
      u = Event.new(valid_event_attributes.except(:user))
      u.save
      assert u.errors.on(:user)
    end    
  end  
  
  def test_should_be_invalid_if_start_time_is_after_end_time
    assert_no_difference Event, :count do
      u = Event.new(valid_event_attributes.merge(:start_time => Time.now, :end_time => 1.week.ago))
      u.save
      assert u.errors.on(:start_time)
    end    
  end

  def test_upcoming_event_scope_should_only_find_future_events
    future_events = Event.upcoming.find_all
    assert_equal future_events.count, 2
    future_events.each {|e| assert e.end_time > Time.now}
  end

  def test_past_event_scope_should_only_find_old_events
    past_events = Event.past.find_all
    assert_equal past_events.count, 3
    past_events.each {|e| assert e.end_time <= Time.now}
  end

  def test_upcoming_events_shown_asc_order
    future_events = Event.upcoming.find(:all)
    assert_equal future_events.first, events(:future_event)
    assert_equal future_events.second, events(:further_future_event) 
  end

  def test_past_events_shown_desc_order
    future_events = Event.past.find(:all)
    assert_equal future_events.first, events(:past_event)
    assert_equal future_events.second, events(:cool_event)
    assert_equal future_events.third, events(:further_past_event) 
  end  

  protected
  def valid_event_attributes
    {:name => 'A great event',
      :user => User.new,
      :start_time => 1.week.ago,
      :end_time => 4.days.ago,      
      :description => 'This will be fun',
      :metro_area => MetroArea.new
    }
  end

end
