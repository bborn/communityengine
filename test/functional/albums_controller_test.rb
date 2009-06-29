require File.dirname(__FILE__) + '/../test_helper'

class AlbumsControllerTest < ActionController::TestCase
  fixtures :photos, :users, :albums
  
  #User should be the owner
  test "should get new" do
    login_as :quentin
    get :new, :user => users(:quentin), :user_id => users(:quentin)
    assert_response :success
  end

  test "should only create album" do
    login_as :quentin
    assert_difference Album, :count, 1 do   
      post :create, :album => {:title => 'Some title', :user => users(:quentin) }, :go_to => 'only_create'
    end
    assert_redirected_to user_photo_manager_index_path(users(:quentin))
  end

  test "should create album" do
    login_as :quentin
    assert_difference Album, :count, 1 do  
      post :create, :album => {:title => 'Some title', :user => users(:quentin) }
    end
    assert_redirected_to new_user_album_photo_path(users(:quentin),Album.last)
  end
  
  test "should not create album" do
    login_as :quentin
    assert_no_difference Album, :count do      
      post :create, :abum => {:description => 'Some content'}
    end
    assert_response 200
  end

  test "should get edit" do
    login_as :quentin
    get :edit, :id => albums(:one).id
    assert_response :success
  end

  test "should update album" do
    login_as :quentin
    put :update, :id => albums(:one).id, :album => { }
    assert_redirected_to user_album_path(users(:quentin), albums(:one))
  end

  test "should destroy album" do
    login_as :quentin
    assert_difference Album, :count, -1 do   
      delete :destroy, :id => albums(:one).id, :user => users(:quentin)
    end
    assert_redirected_to user_photo_manager_index_path(users(:quentin))
  end

  test "photos should be destroyed" do
    login_as :quentin
    assert_difference Photo, :count, -1 do  
      delete :destroy, :id => albums(:one).id, :user => users(:quentin)
    end
    assert_redirected_to user_photo_manager_index_path(users(:quentin))
  end
  
  test "owner should no update counter" do
    login_as :quentin
    get :show, :id => 1
    assert_equal assigns(:album).reload.view_count, 0
  end
  
  test "other user should update counter" do
    login_as :quentin
    get :show, :id => 2
    assert_equal assigns(:album).reload.view_count, 1
  end  
  
  # Public access
  test "should show album and no update counter" do
    get :show, :id => 1
    assert_response :success
    assert assigns(:album)
    assert_equal assigns(:album_photos).size, 1  
    assert_equal assigns(:album).reload.view_count, 0
  end
  
  # User should not get access
  test "other user should not get new" do
    testing_no_owner('get',:new)
    login_as :joe
    testing_no_owner('get',:new)
  end  

  test "other user should not create" do
    testing_no_owner('post',:create)
    login_as :joe
    testing_no_owner('post',:create)
  end  

  test "other user should not update" do
    testing_no_owner('put',:update)
    login_as :joe
    testing_no_owner('update',:update)
  end  

  test "other user should not edit" do
    testing_no_owner('get',:edit)
    login_as :joe
    testing_no_owner('get',:edit)
  end  

  test "other user should not destroy" do
    testing_no_owner('delete',:destroy)
    login_as :joe
    testing_no_owner('delete',:destroy)
  end

  def testing_no_owner(meth,act)
    user_params = {:user => users(:quentin), :user_id => users(:quentin)}
    case meth
      when 'get'
        get act, user_params
      when 'post'
        post act, user_params
      when 'put'
        put act, user_params
      when 'delete'
        delete act, user_params
    end 
    assert_response 302
  end
  
  
  
end
