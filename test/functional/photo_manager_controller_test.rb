require File.dirname(__FILE__) + '/../test_helper'

class PhotoManagerControllerTest < ActionController::TestCase
  fixtures :users, :albums, :photos
  
  test "should get index" do
    login_as :quentin
    get :index, :user => users(:quentin), :user_id => users(:quentin)
    assert_response :success
    assert_equal assigns(:albums).results[0].id, 1
    assert assigns(:photos_no_albums).results, [photos(:another_pic)]
  end
  
  test "should not get index" do
    get :index, :user => users(:quentin), :user_id => users(:quentin)
    assert_response 302
    login_as :quentin 
    get :index, :user => users(:kevin), :user_id => users(:kevin)
    assert_response 302
  end
end
