require 'test_helper'

class AdsControllerTest < ActionController::TestCase
  fixtures :ads, :users, :categories, :roles

  def setup
    login_as :admin
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:ads)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_ad
    old_count = Ad.count
    post :create, :ad => { :html => 'Our company is great!', :frequency => 1, :audience => 'all'}
    assert_equal old_count+1, Ad.count
    
    assert_redirected_to ad_path(assigns(:ad))
  end

  def test_should_show_ad
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_ad
    patch :update, :id => 1, :ad => { }
    assert_redirected_to ad_path(assigns(:ad))
  end
  
  def test_should_destroy_ad
    old_count = Ad.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Ad.count
    
    assert_redirected_to ads_path
  end
end
