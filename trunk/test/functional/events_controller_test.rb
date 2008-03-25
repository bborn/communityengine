require File.dirname(__FILE__) + '/../test_helper'
require 'events_controller'

# Re-raise errors caught by the controller.
class EventsController; def rescue_action(e) raise e end; end

class EventsControllerTest < Test::Unit::TestCase
  fixtures :users, :events, :states

  def setup
    @controller = EventsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:events)
  end

  def test_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end

  def test_should_create_event
    login_as :admin
    assert_difference Event, :count, 1 do
      post :create, :event => {:name => 'New event', :start_time => 1.day.ago, :end_time => Time.now, :description => "A great event" } 
    end
    assert_redirected_to events_path
  end

  def test_should_fail_to_create_event
    login_as :admin
    assert_no_difference Event, :count do
      post :create, :event => { } 
    end
    assert_response :success
  end

  def test_should_get_edit
    login_as :admin
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_event
    login_as :admin
    put :update, :id => 1, :event => {:name => 'changed name' }
    assert_redirected_to events_path
  end

  def test_should_fail_to_update_event
    login_as :admin
    put :update, :id => 1, :event => { :name => nil }
    assert assigns(:event).errors.on(:name)
    assert_response :success
  end

  def test_should_destroy_event
    login_as :admin
    assert_difference Event, :count, -1 do
      delete :destroy, :id => 1
    end
    assert_redirected_to events_path
  end

end