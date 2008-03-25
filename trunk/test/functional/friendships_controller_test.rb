require File.dirname(__FILE__) + '/../test_helper'
require 'friendships_controller'

# Re-raise errors caught by the controller.
class FriendshipsController; def rescue_action(e) raise e end; end

class FriendshipsControllerTest < Test::Unit::TestCase
  include UsersHelper
  fixtures :friendships, :friendship_statuses, :users


  def setup
    @controller = FriendshipsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_accepted_friends_list
    login_as :quentin
    get :accepted, :user_id => users(:quentin).id
    assert_response :success
    assert assigns(:friendships)
  end

  def test_should_get_pending_friends_list
    login_as :aaron
    get :pending, :user_id => users(:aaron).id
    assert_response :success
    assert !assigns(:friendships).empty?
  end

  def test_should_create_friendship_with_notification
    login_as :quentin
    assert_difference Friendship, :count, 2 do
      assert_difference ActionMailer::Base.deliveries, :length, 1 do
        post :create, :user_id => users(:quentin).id, :friend_id => users(:kevin).id 
      end
    end
    assert_redirected_to accepted_user_friendships_path(users(:quentin))
  end

  def test_should_create_friendship_without_notification
    users(:kevin).notify_friend_requests = false
    users(:kevin).save!
    login_as :quentin
    assert_difference Friendship, :count, 2 do
      assert_no_difference ActionMailer::Base.deliveries, :length do
        post :create, :user_id => users(:quentin).id, :friend_id => users(:kevin).id 
      end
    end
    assert_redirected_to accepted_user_friendships_path(users(:quentin))
  end


  def test_should_fail_to_create_friendship
    login_as :quentin
    assert_no_difference Friendship, :count do
      post :create, :user_id => users(:quentin).id, :friend_id => nil
    end
    assert_redirected_to user_friendships_path(users(:quentin))
  end
  
  def test_should_show_friendship
    login_as :quentin
    get :show, :id => friendships(:quentin_init_aaron_pending).id, :user_id => users(:quentin)
    assert_response :success
  end

  def test_should_get_edit
    login_as :aaron
    get :edit, :id => friendships(:aaron_receive_quentin_pending).id, :user_id => users(:aaron)
    assert_response :success
  end
    
  def test_should_accept_friendship
    login_as :aaron
    put :accept, :id => friendships(:aaron_receive_quentin_pending).id, :user_id => users(:aaron)
    assert_redirected_to accepted_user_friendships_path(users(:aaron))
    assert_equal friendships(:aaron_receive_quentin_pending).reload.friendship_status_id, friendship_statuses(:accepted).id
  end

  def test_should_deny_friendship
    login_as :aaron
    put :deny, :id => friendships(:aaron_receive_quentin_pending).id, :user_id => users(:aaron)
    assert_redirected_to denied_user_friendships_path(users(:aaron))
    assert_equal friendships(:aaron_receive_quentin_pending).reload.friendship_status_id, friendship_statuses(:denied).id
  end
  
  def test_should_destroy_friendship
    login_as :quentin
    assert_difference Friendship, :count, -2 do
      delete :destroy, :id => 1, :user_id => users(:quentin).id
      assert_redirected_to accepted_user_friendships_path(:user_id => users(:quentin))
    end
  end
  
  def test_should_ask_if_friends_and_return_false
    assert_nil friends?(users(:quentin), users(:aaron))
  end
  
  def test_should_ask_if_friends_and_return_true
    friendships(:quentin_init_aaron_pending).friendship_status_id = friendship_statuses(:accepted).id
    friendships(:quentin_init_aaron_pending).save!
    friendships(:aaron_receive_quentin_pending).friendship_status_id = friendship_statuses(:accepted).id
    friendships(:aaron_receive_quentin_pending).save!    
    assert friends?(users(:quentin), users(:aaron))
  end
  
  
end
