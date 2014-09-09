require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  fixtures :users, :categories, :roles
  
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
    users(:quentin).update_attribute('activation_code', 'test')
    users(:quentin).update_attribute('activated_at', nil)

    login_as :quentin
    patch :activate_user, :id => users(:quentin).id
    assert !users(:quentin).active?
    assert_redirected_to login_path
  end
  
  def test_should_not_activate_user_js
    users(:quentin).update_attribute('activation_code', 'test')
    users(:quentin).update_attribute('activated_at', nil)

    xhr :get, :activate_user, :id => users(:quentin).id, :format => :js
    assert !users(:quentin).active?
  end
  

  def test_should_activate_user
    users(:quentin).update_attribute('activation_code', 'test')
    users(:quentin).update_attribute('activated_at', nil)    

    login_as :admin
    patch :activate_user, :id => users(:quentin).id
    assert_response :redirect    
    assert users(:quentin).reload.active?
  end
  
  def test_should_deactivate_user
    login_as :admin
    patch :deactivate_user, :id => users(:quentin).id
    assert_response :redirect    
    assert !users(:quentin).reload.active?    
  end
  
  test "should list users" do
    login_as :admin
    get :users
    assert_response :success
    assert !assigns(:users).empty?
  end
  
  test "should search users" do
    login_as :admin
    get :users, :login => 'uenti'
    assert_response :success
    assert_equal assigns(:users).first, users(:quentin)
  end
  
  test "should clear cache" do
    login_as :admin
    get :clear_cache
    assert_redirected_to admin_dashboard_path
  end
  
  test "should get subscribers xml" do
    authorize_as :admin

    get :subscribers, :format => :xml
    assert_response :success
    assert assigns(:users).any?
  end

end
