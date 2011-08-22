require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  fixtures :users, :events, :states, :roles

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
    assert_redirected_to event_path(assigns(:event))
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
    assert_redirected_to event_path(assigns(:event))
  end

  def test_should_fail_to_update_event
    login_as :admin
    put :update, :id => 1, :event => { :name => nil }
    assert assigns(:event).errors[:name]
    assert_response :success
  end

  def test_should_destroy_event
    @request.env["HTTP_REFERER"] = 'http://test.host/admin/events'
    login_as :admin
    assert_difference Event, :count, -1 do
      delete :destroy, :id => 1
    end
    assert_redirected_to admin_events_path
  end

  def test_index_should_show_link_to_past_only
    login_as :admin
    get :index
    assert_tag :tag=>'a', :attributes=>{:href=>'/events/past'}, :content=> :past_events.l
    assert_no_tag :tag=>'a', :attributes=>{:href=>'/events'}, :content=> :upcoming_events.l
  end

  def test_past_should_show_link_to_index_only
    login_as :admin
    get :past
    assert_no_tag :tag=>'a', :attributes=>{:href=>'/events/past'}, :content=> :past_events.l
    assert_tag :tag=>'a', :attributes=>{:href=>'/events'}, :content=> :upcoming_events.l
  end

  def test_should_get_ical
    get :ical, :format => 'ics'
    assert_response :success
    assert assigns(:calendar)
  end

  def test_should_show_rsvp
    login_as :admin
    get :show, :id=>2
    assert_tag :tag=>'a', :content=>:rsvp.l
    assert_tag :tag=>'b', :content=>"#{:rsvps.l}:"
  end

  def test_should_not_show_rsvp
    login_as :admin
    get :show, :id=>6
    assert_no_tag :tag=>'a', :content=>:rsvp.l
    assert_no_tag :tag=>'b', :content=>"#{:rsvps.l}:"
  end
  
  def test_should_clone_event
    login_as :admin
    get :clone, :id => events(:cool_event)
        
    assert_equal assigns(:event).attributes.slice(:name, :start_time, :end_time, :description), events(:cool_event).attributes.slice(:name, :start_time, :end_time, :description)    
  end

end
