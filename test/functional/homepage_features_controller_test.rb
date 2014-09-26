require 'test_helper'

class HomepageFeaturesControllerTest < ActionController::TestCase
  fixtures :all

  def test_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:homepage_features)
  end

  def test_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end
  
  def test_should_create_homepage_feature
    login_as :admin
    assert_difference HomepageFeature, :count, 1 do
      post :create, :homepage_feature => {:title => 'feature', :url => 'example.com', :image => fixture_file_upload('/files/library.jpg', 'image/jpg') } 
    end
    assert_redirected_to homepage_feature_path(assigns(:homepage_feature))
  end

  def test_should_fail_to_create_homepage_feature
    login_as :admin
    assert_no_difference HomepageFeature, :count do
      post :create, :homepage_feature => { } 
    end
    assert_response :success
  end


  def test_should_show_homepage_feature
    login_as :admin
    get :show, :id => homepage_features(:community_tour).id
    assert_response :success
  end

  def test_should_get_edit
    login_as :admin
    get :edit, :id => homepage_features(:community_tour).id
    assert_response :success
  end
  
  def test_should_update_homepage_feature
    login_as :admin
    patch :update, :id => homepage_features(:community_tour).id, :homepage_feature => {:url => 'changed_url.com' }
    assert_redirected_to homepage_feature_path(assigns(:homepage_feature))
  end

  def test_should_fail_to_update_homepage_feature
    login_as :admin
    patch :update, :id => homepage_features(:community_tour).id, :homepage_feature => { :url => nil }
    assert assigns(:homepage_feature).errors[:url]
    assert_response :success
  end

  
  def test_should_destroy_homepage_feature
    login_as :admin
    assert_difference HomepageFeature, :count, -1 do
      delete :destroy, :id => homepage_features(:community_tour).id
    end
    assert_redirected_to homepage_features_path
  end
end
