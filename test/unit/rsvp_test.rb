require File.dirname(__FILE__) + '/../test_helper'

class RsvpTest < ActiveSupport::TestCase
  
  fixtures :events, :users

  def test_should_be_invalid_with_invalid_attendees_count
    e = events(:future_event)
    u = users(:quentin)
    ['',0,-1,3.5].each do |c|
      assert_no_difference Rsvp, :count do
        r = e.rsvps.build(:attendees_count=>c)
        r.user = u
        r.save
        assert r.errors[:attendees_count]
      end
    end    
  end

  def test_should_be_invalid_with_event_that_does_not_allow_rsvp
    e = events(:no_rsvp_event)
    u = users(:quentin)
    assert_no_difference Rsvp, :count do
      r = e.rsvps.build(:attendees_count=>1)
      r.user = u
      r.save
      assert r.errors[:base]
    end    
  end

end
