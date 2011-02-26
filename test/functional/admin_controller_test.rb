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
    login_as :quentin
    users(:quentin).update_attribute('activation_code', 'test')
    users(:quentin).update_attribute('activated_at', nil)    
        
    put :activate_user, :id => 1
    assert !users(:quentin).active?
    assert_redirected_to login_path
  end
  
  def test_should_not_activate_user_js
    users(:quentin).update_attribute('activation_code', 'test')
    users(:quentin).update_attribute('activated_at', nil)    
    
    get :activate_user, :id => 1, :format => 'js'
    assert !users(:quentin).active?
  end
  

  def test_should_activate_user
    users(:quentin).update_attribute('activation_code', 'test')
    users(:quentin).update_attribute('activated_at', nil)    

    login_as :admin
    put :activate_user, :id => users(:quentin).id
    assert_response :redirect    
    assert users(:quentin).reload.active?
  end
  
  def test_should_deactivate_user
    login_as :admin
    put :deactivate_user, :id => users(:quentin).id
    assert_response :redirect    
    assert !users(:quentin).reload.active?    
  end
  
  test "should clear cache" do
    login_as :admin
    get :clear_cache
    assert_redirected_to admin_dashboard_path
  end

end
