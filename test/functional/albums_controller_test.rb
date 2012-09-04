require 'test_helper'

class AlbumsControllerTest < ActionController::TestCase
  fixtures :photos, :users, :albums
  
  #User should be the owner
  test "should get new" do
    login_as :quentin
    get :new, :user_id => users(:quentin)
    assert_response :success
  end

  test "should only create album" do
    login_as :quentin
    assert_difference Album, :count, 1 do   
      post :create, :user_id => users(:quentin), :album => {:title => 'Some title', :user_id => users(:quentin) }, :go_to => 'only_create'
    end
    assert_redirected_to user_photo_manager_index_path(users(:quentin))
  end

  test "should create album" do
    login_as :quentin
    assert_difference Album, :count, 1 do  
      post :create, :user_id => users(:quentin), :album => {:title => 'Some title', :user_id => users(:quentin) }
    end
    assert_redirected_to new_user_album_photo_path(users(:quentin),Album.last)
  end
  
  test "should not create album" do
    login_as :quentin
    assert_no_difference Album, :count do      
      post :create, :user_id => users(:quentin), :album => {:description => 'Some content'}, :user_id => users(:quentin)
    end
    assert_response 200
  end

  test "should get edit" do
    login_as :quentin
    get :edit, :id => albums(:one).id, :user_id => users(:quentin)
    assert_response :success
  end

  test "should update album" do
    login_as :quentin
    put :update, :id => albums(:one).id, :album => { }, :go_to => 'only_create', :user_id => users(:quentin)
    assert_redirected_to user_album_path(users(:quentin), albums(:one))
    put :update, :id => albums(:one).id, :album => { }, :go_to => '', :user_id => users(:quentin)
    assert_redirected_to new_user_album_photo_path(users(:quentin),albums(:one))
  end

  test "should destroy album" do
    login_as :quentin
    assert_difference Album, :count, -1 do   
      delete :destroy, :id => albums(:one).id, :user_id => users(:quentin)
    end
    assert_redirected_to user_photo_manager_index_path(users(:quentin))
  end

  test "photos should be destroyed" do
    login_as :quentin
    assert_difference Photo, :count, -1 do  
      delete :destroy, :id => albums(:one).id, :user_id => users(:quentin)
    end
    assert_redirected_to user_photo_manager_index_path(users(:quentin))
  end
  
  test "owner should not update counter" do
    login_as :quentin
    get :show, :id => albums(:one).id, :user_id => users(:quentin)
    assert_equal assigns(:album).reload.view_count, 0
  end
  
  test "Non owners should update counter" do
    login_as :quentin
    get :show, :id => 2, :user_id => users(:quentin)
    assert_equal assigns(:album).reload.view_count, 1
  end  
  
  # Public access
  test "should show album and not update counter" do
    get :show, :id => 1, :user_id => users(:quentin)
    assert_response :success
    assert assigns(:album)
    assert_equal assigns(:album_photos).size, 1  
    assert_equal assigns(:album).reload.view_count, 0
  end
  

  test "should not create albums for another user" do
    login_as :joe
    assert_no_difference Album, :count do
      post :create, :user_id => users(:quentin), :album => {:title => 'Foo'}
    end
    assert_response :redirect
  end  

  test "should not update another user's album" do
    login_as :joe
    put :update, :user_id => users(:quentin), :id => albums(:one), :album => {:title => 'Fooo!'}
    assert !albums(:one).reload.title.eql?('Fooo!')
    assert_response :redirect
  end  

  test "should not edit another user's album" do
    login_as :joe
    get :edit, :user_id => users(:quentin), :id => albums(:one)
    assert_response :redirect
  end  

  test "should not destroy another user's album" do
    login_as :joe

    assert_no_difference Album, :count do
      delete :destroy, :user_id => users(:quentin), :id => albums(:one)      
    end
    
    assert_response :redirect
  end  
  
end
