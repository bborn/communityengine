require File.dirname(__FILE__) + '/../test_helper'
require 'photos_controller'

# Re-raise errors caught by the controller.
class PhotosController; def rescue_action(e) raise e end; end

class PhotosControllerTest < Test::Unit::TestCase
  fixtures :photos, :users, :roles

  def setup
    @controller = PhotosController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index, :user_id => users(:quentin).id
    assert_response :success
    assert assigns(:photos)
  end


  def test_should_get_index_rss
    get :index, :user_id => users(:quentin).id, :format => 'rss'
    assert_response :success
    assert assigns(:photos)
  end

  def test_should_not_get_index_for_private_user
    get :index, :user_id => users(:privateuser).id
    assert_response :redirect
  end

  def test_should_get_index_for_private_if_logged_in
    login_as :quentin
    get :index, :user_id => users(:privateuser).id
    assert_response :success
    assert assigns(:photos)
  end


  def test_should_get_recent
    get :recent
    assert_response :success
    assert assigns(:photos)
  end

  def test_should_get_new
    login_as :quentin
    get :new, :user_id => users(:quentin).id
    assert_response :success
  end
  
  def test_should_create_photo
    login_as :quentin
    assert_difference Photo, :count, 1 do
      post :create, :photo => {:uploaded_data => fixture_file_upload('/files/library.jpg', 'image/jpg') }, :user_id => users(:quentin).id
      assert_equal assigns(:photo).user, users(:quentin)
    end
  end

  def test_should_create_photo
    assert_recognizes({:controller => 'photos', :action => 'create', :format => 'js'}, '/create_photo.js')
  end

  def test_should_fail_to_create_photo
    login_as :quentin
    assert_no_difference Photo, :count do
      post :create, :photo => { }, :user_id => users(:quentin).id
    end
    assert_response :success
  end

  def test_should_fail_content_type
    login_as :quentin
    assert_no_difference Photo, :count do
      post :create, :photo => {:uploaded_data => fixture_file_upload('/files/Granite.bmp', 'image/bmp') }, :user_id => users(:quentin).id
    end
    assert_response :success
  end

  def test_should_show_photo
    get :show, :id => photos(:library_pic).id, :user_id => users(:quentin).id
    assert_response :success
  end

  def test_should_show_private_photo_if_logged_in
    login_as :quentin
    get :show, :id => photos(:library_pic).id, :user_id => users(:privateuser).id
    assert_response :success
  end
  
  def test_should_not_show_private_photo
    get :show, :id => photos(:library_pic).id, :user_id => users(:privateuser).id
    assert_response :redirect    
  end


  def test_should_get_edit
    login_as :quentin
    get :edit, :id => photos(:library_pic).id, :user_id => users(:quentin).id
    assert_response :success
  end
  
  def test_should_update_photo
    login_as :quentin
    put :update, :id => photos(:library_pic).id, :user_id => users(:quentin).id, :photo => { :name => "changed_name" }
    assert_redirected_to user_photo_path(users(:quentin), assigns(:photo))
    assert_equal assigns(:photo).name, "changed_name"
  end

  def test_should_fail_to_update_photo
    login_as :quentin
    put :update, :id => photos(:library_pic).id, :user_id => users(:aaron).id, :photo => { :size => nil }
    assert_response :redirect
  end

  
  def test_should_destroy_photo
    login_as :quentin
    assert_difference Photo, :count, -1 do
      delete :destroy, :id => photos(:library_pic), :user_id => users(:quentin).id
    end
    assert_redirected_to user_photos_path(:user_id => users(:quentin) )
  end
  
  def test_should_not_destroy_photo
    login_as :quentin
    assert_difference Photo, :count, 0 do
      delete :destroy, :id => photos(:library_pic), :user_id => users(:aaron).id
    end
    assert_redirected_to new_session_path
  end
  
  def test_should_remove_avatar_when_photo_is_destroyed
    login_as :quentin
    users(:quentin).avatar = photos(:library_pic)
    users(:quentin).save!
    assert_difference Photo, :count, -1 do
      delete :destroy, :id => 1, :user_id => users(:quentin).id
    end
    assert users(:quentin).reload.avatar.nil?
  end
  
  def test_should_get_slideshow
    get :slideshow, :user_id => users(:quentin)
    assert_response :success
  end
  
  
end
