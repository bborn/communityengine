require 'test_helper'

class ClippingsControllerTest < ActionController::TestCase
  fixtures :all

  def setup
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
  
  test "should get site index with recent param" do
    get :site_index, :recent => 'true'
    assert_response :success    
    assert_select 'a[href*=/clippings]'
  end

  test "should get site index without recent param" do
    get :site_index
    assert_response :success
    assert_select 'a[href*=/clippings?recent=true]'
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
      post :create,
        :user_id => users(:quentin),
        :clipping => {:url => 'http://www.google.com', :image_url => 'http://www.google.com/intl/en_ALL/images/logo.gif'},
        :tag_list => 'tag1, tag2'
      assert_redirected_to user_clipping_path(users(:quentin), assigns(:clipping))

      clipping = Clipping.find(assigns(:clipping).id)
      assert_equal ['tag1', 'tag2'], clipping.tag_list.sort
    end    
  end

  def test_should_create_clipping_from_bookmarklet
    login_as :quentin
    get :new_clipping, :uri => 'http://www.google.com'
    assert_response :success
    assert !assigns(@images).empty?
  end
  
  def test_load_images_from_uri
    post :load_images_from_uri, :uri => 'http://www.google.com', :format => :js
    assert_response :success
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
    put :update, :id => 1,
      :clipping => {:url => 'changed url'},
      :user_id => users(:quentin),
      :tag_list => 'tagX, tagY'
    assert_redirected_to user_clipping_path(users(:quentin), assigns(:clipping))

    clipping = Clipping.find(assigns(:clipping).id)
    assert_equal ['tagX', 'tagY'], clipping.tag_list.sort
  end
  
  def test_should_destroy_clipping
    login_as :quentin
    assert_difference Clipping, :count, -1 do
      delete :destroy, :id => 1, :user_id => users(:quentin)
      assert_redirected_to user_clippings_path(users(:quentin))
    end
    
  end
end
