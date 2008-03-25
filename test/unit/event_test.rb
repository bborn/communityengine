require File.dirname(__FILE__) + '/../test_helper'

class EventTest < Test::Unit::TestCase
  
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