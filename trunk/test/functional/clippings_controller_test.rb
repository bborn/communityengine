require File.dirname(__FILE__) + '/../test_helper'
require 'clippings_controller'

# Re-raise errors caught by the controller.
class ClippingsController; def rescue_action(e) raise e end; end

class ClippingsControllerTest < Test::Unit::TestCase
  fixtures :clippings, :users

  def setup
    @controller = ClippingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    Asset.destroy_all    
  end
  
  def test_should_get_index
    login_as :quentin
    get :index, :user_id => users(:quentin)
    assert_response :success
    assert assigns(:clippings)
  end

  def test_should_get_index_rss
    login_as :quentin
    get :index, :user_id => users(:quentin), :format => 'rss'
    assert_response :success
    assert assigns(:clippings)
  end


  def test_should_get_private_index_if_logged_in
    login_as :quentin
    get :index, :user_id => users(:privateuser)
    assert_response :success
    assert assigns(:clippings)
  end
  
  def test_should_not_get_private_index
    get :index, :user_id => users(:privateuser)
    assert_response :redirect
  end
  
  def test_should_get_site_index
    get :site_index
    assert_response :success
    assert !assigns(:clippings).empty?
  end

  def test_should_get_site_index_rss
    get :site_index, :format => 'rss'
    assert_response :success
    assert !assigns(:clippings).empty?
  end


  def test_should_get_new
    login_as :quentin
    get :new, :user_id => users(:quentin)
    assert_response :success
  end
  
  def test_should_create_clipping
    login_as :quentin
    assert_difference Clipping, :count, 1 do
      post :create, :user_id => users(:quentin), :clipping => {:url => 'http://www.google.com', :image_url => 'http://www.google.com/intl/en/images/logo.gif' }
      assert_redirected_to user_clipping_path(users(:quentin), assigns(:clipping))
    end    
  end

  def test_should_create_clipping_from_bookmarklet
    login_as :quentin
    get :new_clipping, :uri => 'http://www.google.com'
    assert_response :success
    assert !assigns(@images).empty?
  end


  def test_should_show_clipping
    login_as :quentin
    get :show, :id => 1, :user_id => users(:quentin)
    assert_response :success
  end

  def test_should_get_edit
    login_as :quentin
    get :edit, :id => 1, :user_id => users(:quentin)
    assert_response :success
  end
  
  def test_should_update_clipping
    login_as :quentin
    put :update, :id => 1, :clipping => {:url => 'changed url' }, :user_id => users(:quentin)
    assert_redirected_to user_clipping_path(users(:quentin), assigns(:clipping))
  end
  
  def test_should_destroy_clipping
    login_as :quentin
    assert_difference Clipping, :count, -1 do
      delete :destroy, :id => 1, :user_id => users(:quentin)
      assert_redirected_to user_clippings_path(users(:quentin))
    end
    
  end
end
