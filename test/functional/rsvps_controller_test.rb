require File.dirname(__FILE__) + '/../test_helper'

class RsvpsControllerTest < ActionController::TestCase
  fixtures :users, :events, :rsvps

  def test_should_route_rsvp_of_event
    login_as :quentin
    options = {:controller => 'rsvps', :action => 'new', :event_id => "2"}
    assert_routing('events/2/rsvps/new', options)
  end

  def test_should_get_new
    login_as :quentin
    get :new, :event_id => "2"
    assert_response :success
  end

  def test_should_create_rsvp
    login_as :quentin
    assert_difference Rsvp, :count, 1 do
      post :create, :event_id => "3", :rsvp => {:attendees_count => 1} 
    end
    assert_redirected_to event_path(events(:further_future_event))
  end

  def test_should_fail_to_create_rsvp
    login_as :quentin
    assert_no_difference Rsvp, :count do
      post :create, :event_id => "2", :rsvp => { } 
    end
    assert_response :success
  end

  def test_should_fail_to_create_rsvp_for_past_event
    login_as :quentin
    assert_no_difference Rsvp, :count do
      post :create, :event_id => "1", :rsvp => {:attendees_count=>1} 
    end
    assert_response :success
  end

  def test_should_fail_to_create_rsvp_twice_for_event
    login_as :quentin
    assert_no_difference Rsvp, :count do
      post :create, :event_id => "2", :rsvp => {:attendees_count=>1} 
    end
    assert_response :success
  end

  def test_should_fail_to_create_rsvp_for_event_that_does_not_allow_rsvps
    login_as :quentin
    assert_no_difference Rsvp, :count do
      post :create, :event_id => "6", :rsvp => {:attendees_count=>1} 
    end
    assert_response :success
  end

  def test_should_get_edit
    login_as :quentin
    get :edit, :event_id => "2", :id => 1
    assert_response :success
  end

  def test_should_update_rsvp
    login_as :quentin
    put :update, :event_id => "2", :id => 1, :rsvp => {:attendees_count => '3' }
    assert_redirected_to event_path(events(:future_event))
  end

  def test_should_fail_to_update_rsvp
    login_as :quentin
    put :update, :event_id => "2", :id => 1, :rsvp => { :attendees_count => nil }
    assert assigns(:rsvp).errors.on(:attendees_count)
    assert_response :success
  end

  def test_should_fail_to_update_rsvp_for_other_user
    login_as :aaron
    put :update, :event_id => "2", :id => 1, :rsvp => { :attendees_count => '3' }
    assert_equal Rsvp.find(1).attendees_count, 2
    assert_redirected_to event_path(events(:future_event))
  end

  def test_should_destroy_rsvp
    login_as :quentin
    assert_difference Rsvp, :count, -1 do
      delete :destroy, :event_id => "2", :id => 1
    end
    assert_redirected_to event_path(events(:future_event))
  end

end
