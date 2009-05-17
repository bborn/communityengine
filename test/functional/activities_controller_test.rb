require File.dirname(__FILE__) + '/../test_helper'

class ActivitiesControllerTest < ActionController::TestCase
  fixtures :users, :categories, :posts, :comments, :roles

  def setup
    @controller = ActivitiesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_network
    login_as :quentin
    get :network, :id => users(:quentin)
    assert_response :success
  end
  
  def test_should_delete_activity
    @request.env["HTTP_REFERER"] = '/'
    
    login_as :quentin
    users(:quentin).track_activity(:logged_in)
    
    assert_difference Activity, :count, -1 do
      delete :destroy, :id => Activity.last.id      
    end
    
    assert_response :redirect
  end
  
  def test_should_not_delete_activity
    @request.env["HTTP_REFERER"] = '/'
    
    login_as :quentin
    users(:aaron).track_activity(:logged_in)
    
    assert_difference Activity, :count, 0 do
      delete :destroy, :id => Activity.last.id      
    end
    
    assert_response :redirect    
  end
  
  def test_should_delete_activity_as_admin
    @request.env["HTTP_REFERER"] = '/'
    
    login_as :admin
    users(:quentin).track_activity(:logged_in)
    
    assert_difference Activity, :count, -1 do
      delete :destroy, :id => Activity.last.id      
    end
    
    assert_response :redirect    
  end

end
