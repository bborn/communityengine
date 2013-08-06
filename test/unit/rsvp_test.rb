require 'test_helper'

class RsvpTest < ActiveSupport::TestCase
  
  fixtures :events, :users

  def test_should_be_invalid_with_invalid_attendees_count
    event = events(:future_event)
    user = users(:quentin)
    ['',0,-1,3.5].each do |c|
      assert_no_difference Rsvp, :count do
        rsvp = Rsvp.new(:attendees_count=>c)
        rsvp.event = event
        rsvp.user = user
        rsvp.save
        assert rsvp.errors[:attendees_count]
      end
    end    
  end

  def test_should_be_invalid_with_event_that_does_not_allow_rsvp
    event = events(:no_rsvp_event)
    user = users(:quentin)
    assert_no_difference Rsvp, :count do
      rsvp = Rsvp.new(:attendees_count=>1)
      rsvp.event = event
      rsvp.user = user
      rsvp.save
      assert rsvp.errors[:base]
    end    
  end

end
