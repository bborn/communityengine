require File.dirname(__FILE__) + '/../test_helper'
require 'homepage_features_controller'

# Re-raise errors caught by the controller.
class HomepageFeaturesController; def rescue_action(e) raise e end; end

class HomepageFeaturesControllerTest < Test::Unit::TestCase
  fixtures :homepage_features, :users

  def setup
    @controller = HomepageFeaturesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

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
      post :create, :homepage_feature => {:url => 'example.com', :uploaded_data => fixture_file_upload('/files/library.jpg', 'image/jpg') } 
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
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    login_as :admin
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_homepage_feature
    login_as :admin
    put :update, :id => 1, :homepage_feature => {:url => 'changed_url.com' }
    assert_redirected_to homepage_feature_path(assigns(:homepage_feature))
  end

  def test_should_fail_to_update_homepage_feature
    login_as :admin
    put :update, :id => 1, :homepage_feature => { :url => nil }
    assert assigns(:homepage_feature).errors.on(:url)
    assert_response :success
  end

  
  def test_should_destroy_homepage_feature
    login_as :admin
    assert_difference HomepageFeature, :count, -1 do
      delete :destroy, :id => 1
    end
    assert_redirected_to homepage_features_path
  end
end
