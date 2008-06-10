require File.dirname(__FILE__) + '/../test_helper'
require 'posts_controller'

# Re-raise errors caught by the controller.
class PostsController; def rescue_action(e) raise e end; end

class PostsControllerTest < Test::Unit::TestCase
  fixtures :posts, :users, :categories, :contests, :roles

  def setup
    @controller = PostsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index, :user_id => users(:quentin).id
    assert_response :success
    assert assigns(:posts)
  end
  
  def test_should_get_index_rss
    get :index, :user_id => users(:quentin).id, :format => 'rss'
    assert_response :success
    assert assigns(:posts)
  end
  
  
  
  def test_should_not_get_index_for_private_user
    get :index, :user_id => users(:privateuser).id
    assert_response :redirect
  end

  def test_should_get_new
    login_as :quentin
    get :new, :user_id => users(:quentin).id
    assert_response :success
  end
  
  def test_should_create_post
    login_as :quentin
    assert_difference Post, :count, 1 do
      create_post
      assert_response :redirect
    end
  end

  def test_should_create_contest_post
    login_as :quentin
    assert_difference Post, :count, 1 do
      post :create, {:user_id => users(:quentin).id, :post => { :title => 'dude', :raw_post => 'rawness', :category => categories(:talk), :contest => contests(:one) } }
      assert_equal Post.find_by_title("dude").contest, contests(:one)
      assert_equal Post.find_by_title("dude").category, categories(:talk)
      assert_response :redirect
    end
  end

  def test_should_show_post
    get :show, :id => posts(:funny_post).id, :user_id => users(:quentin).id
    assert_response :success
  end

  def test_should_show_draft_post
    posts(:funny_post).save_as_draft
    get :show, :id => posts(:funny_post).id, :user_id => users(:quentin).id
    assert_response :success
  end


  def test_should_not_show_post_for_private_user
    get :show, :id => posts(:funny_post).id, :user_id => users(:privateuser).id
    assert_response :redirect
  end

  def test_should_get_edit
    login_as :quentin
    get :edit, :id => posts(:funny_post).id, :user_id => users(:quentin).id
    assert_response :success
  end
  
  def test_should_update_post
    login_as :quentin
    put :update, :id => posts(:funny_post).id, :user_id => users(:quentin).id, :post => { :title => "changed_name" }
    assert_redirected_to user_post_path(users(:quentin), assigns(:post))
    assert_equal assigns(:post).title, "changed_name"
  end

  def test_should_fail_to_update_post
    login_as :quentin
    put :update, :id => posts(:funny_post).id, :user_id => users(:quentin).id, :post => { :title => nil }
    assert_response :success
    assert assigns(:post).errors.on(:title)
  end

  
  def test_should_destroy_post
    login_as :quentin
    assert_difference Post, :count, -1 do
      delete :destroy, :id => posts(:funny_post), :user_id => users(:quentin).id
    end
    assert_redirected_to manage_user_posts_path(:user_id => users(:quentin) )
  end
  
  def test_should_not_destroy_post
    login_as :quentin
    assert_difference Post, :count, 0 do
      delete :destroy, :id => posts(:funny_post), :user_id => users(:aaron).id
    end
    assert_redirected_to new_session_path
  end
  
  def test_should_send_emails_to_friends
    login_as :quentin
    assert_difference ActionMailer::Base.deliveries, :length, 2 do
      post :send_to_friend, :user_id => users(:quentin).id, :id => posts(:funny_post).to_param, :emails => 'test@example.com, test2@example.com', :message => 'you are great, friends'
      assert_response :success
    end
  end

  def test_should_not_send_emails_to_friends
    login_as :quentin
    assert_no_difference ActionMailer::Base.deliveries, :length do
      post :send_to_friend, :user_id => users(:quentin).id, :id => posts(:funny_post).to_param, :emails => 'test_is_and_example.com, test2@example.com', :message => 'you are great, friends'
      assert_response 500
    end
  end

  def test_should_update_emailed_count
    login_as :quentin
    assert_equal posts(:funny_post).emailed_count, 0
    post :send_to_friend, :user_id => users(:quentin).id, :id => posts(:funny_post).to_param, :emails => 'test@example.com, test2@example.com', :message => 'you are great, friends'
    assert_response :success
    assert_equal posts(:funny_post).reload.emailed_count, 1    
  end
  
  def test_should_get_popular
    get :popular
    assert_response :success
  end

  def test_should_get_popular_rss
    get :popular, :format => 'rss'
    assert_response :success
  end


  def test_should_get_recent
    get :recent
    assert_response :success
  end

  def test_should_get_recent
    get :recent, :format => "rss"
    assert_response :success
  end

  
  def test_should_get_featured
    get :featured
    assert_response :success
  end  
  
  def test_should_update_views
    assert_equal 0, posts(:funny_post).view_count
    put :update_views, :user_id => posts(:funny_post).user_id, :id => posts(:funny_post)
    assert_response :success
    assert_equal 1, posts(:funny_post).reload.view_count      
  end
    
  def create_post(options = {})
    post :create, {:user_id => users(:quentin).id, :post => { :title => 'dude', :raw_post => 'rawness', :category => categories(:talk) }.merge(options[:post] || {}) }.merge(options || {})
  end
  
end
