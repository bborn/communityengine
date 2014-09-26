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
    assert_difference Ad, :count do
      post :create, :ad => { :html => 'Our company is great!', :frequency => 1, :audience => 'all'}
    end

    assert_redirected_to ad_path(assigns(:ad))
  end

  def test_should_show_ad
    get :show, :id => ads(:hgtv).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => ads(:hgtv).id
    assert_response :success
  end
  
  def test_should_update_ad
    patch :update, :id => ads(:hgtv).id, :ad => { }
    assert_redirected_to ad_path(assigns(:ad))
  end
  
  def test_should_destroy_ad
    assert_difference Ad, :count, -1 do
      delete :destroy, :id => ads(:hgtv).id
    end

    assert_redirected_to ads_path
  end
end
