require File.dirname(__FILE__) + '/../test_helper'

class StatisticsControllerTest < ActionController::TestCase
  fixtures :users, :roles
  
  def test_should_get_index
    login_as :admin
    get :index
    assert_response :success
  end

  def test_should_not_get_index
    login_as :quentin
    get :index
    assert_redirected_to login_url
  end
    
end
