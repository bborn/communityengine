require File.dirname(__FILE__) + '/../test_helper'

class PhotosControllerTest < ActionController::TestCase
  fixtures :photos, :users, :roles, :albums

  def setup
    @controller = PhotosController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_create_photo
    login_as :quentin 
    assert_difference Photo, :count, 4 do
      post :create,
        :photo => { :uploaded_data => fixture_file_upload('files/library.jpg', 'image/jpg') },
        :user_id => users(:quentin).id,
        :tag_list => 'tag1 tag2',
        :album_id => '1'
      photo = Photo.find(assigns(:photo).id)
      assert_equal users(:quentin), photo.user
      assert_equal ['tag1', 'tag2'], photo.tag_list.sort
      assert_equal albums(:one).photos.count, 2
    end
  end

  def test_should_create_photo_with_swf
    login_as :quentin 
    assert_difference Photo, :count, 4 do
      post :swfupload,
        :Filedata => fixture_file_upload('files/library.jpg', 'image/jpg'),
        :user_id => users(:quentin).id,
        :album_id => '1'
      photo = Photo.find(assigns(:photo).id)
      assert_equal users(:quentin), photo.user

      assert_equal albums(:one).photos.count, 2
    end
  end  
  
  def test_should_not_be_an_activity
    login_as :quentin 
    assert_no_difference Activity, :count  do
     post :create,
        :photo => { :uploaded_data => fixture_file_upload('files/library.jpg', 'image/jpg') },
        :user_id => users(:quentin).id,
        :tag_list => 'tag1 tag2',
        :album_id => '1'
    end
  end
  
  def test_should_update
    login_as :quentin 
    assert_no_difference Photo ,:count do
      post :update, :id => 1, :photo => {:name => 'Another name', :album_id => 2}
    end
    assert_equal photos(:library_pic).name, 'Another name'
    assert_equal photos(:library_pic).album_id, 2    
  end
  
  def owner_should_not_update_view_counter
    login_as :quentin 
    get :show, :id => 1
    assert_equal assigns(:photo).reload.view_count, 0
  end
  
  def other_user_should_update_view_counter
    login_as :quentin 
    get :show, :id => 2
    assert_equal assigns(:photo).reload.view_count, 1
  end
  
  def no_logged_should_not_update_view_counter
    get :show, :id => 1
    assert_equal assigns(:photo).reload.view_count, 0
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
  
  def test_should_create_photo_without_album_id
    login_as :quentin
    assert_difference Photo, :count, 4 do
      post :create,
        :photo => { :uploaded_data => fixture_file_upload('/files/library.jpg', 'image/jpg') },
        :user_id => users(:quentin).id,
        :tag_list => 'tag1 tag2'

      photo = Photo.find(assigns(:photo).id)
      assert_equal users(:quentin), photo.user
      assert_equal ['tag1', 'tag2'], photo.tag_list
    end
  end

  def test_should_create_photo_routing
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
    get :show, :id => photos(:library_pic).id
    assert_response :success
  end
  
  def test_should_not_show_private_photo
    photos(:library_pic).user = users(:privateuser)
    photos(:library_pic).save
    
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
    put :update,
      :id => photos(:library_pic).id,
      :user_id => users(:quentin).id,
      :photo => { :name => "changed_name" },
      :tag_list => 'tagX tagY'

    assert_redirected_to user_photo_path(users(:quentin), assigns(:photo))

    photo = photos(:library_pic).reload
    assert_equal "changed_name", photo.name
    assert_equal ['tagX', 'tagY'], photo.tag_list
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
    assert_redirected_to login_path
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
