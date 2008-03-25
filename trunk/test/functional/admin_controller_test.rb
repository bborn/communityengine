require File.dirname(__FILE__) + '/../test_helper'
require 'admin_controller'

# Re-raise errors caught by the controller.
class AdminController; def rescue_action(e) raise e end; end

class AdminControllerTest < Test::Unit::TestCase
  fixtures :users, :categories

  def setup
    @controller = AdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    login_as :admin
    get :users
    assert_response :success
  end

  def test_should_not_get_index
    login_as :quentin
    get :users
    assert_redirected_to login_path
  end
  
  def test_should_not_activate_user
    login_as :quentin
    put :activate_user
    assert_redirected_to login_path
  end

  def test_should_activate_user
    users(:quentin).update_attribute('activation_code', 'test')
    users(:quentin).update_attribute('activated_at', nil)    

    login_as :admin
    put :activate_user, :id => users(:quentin).id
    assert_response :redirect    
    assert users(:quentin).reload.active?
  end

end
