require File.dirname(__FILE__) + '/../test_helper'
require 'comments_controller'

# Re-raise errors caught by the controller.
class CommentsController; def rescue_action(e) raise e end; end

class CommentsControllerTest < Test::Unit::TestCase
  fixtures :users, :photos, :posts, :comments

  def setup
    @controller = CommentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_create_user_comment_with_notification
    login_as :aaron
    assert_difference Comment, :count, 1 do
      assert_difference ActionMailer::Base.deliveries, :length, 1 do
        create_user_comment
      end
    end
    assert_response :redirect
  end
  
  def test_should_create_user_comment_and_notify_previous_commenters
    login_as :dwr
    # aaron should get a notification, because he's being commented on
    # quentin should get one too, because he previously commented on the profile
    assert_difference ActionMailer::Base.deliveries, :length, 2 do
      create_user_comment(:user_id => users(:aaron).id)
    end
  end  
  

  def test_should_create_user_comment_without_notification
    users(:quentin).notify_comments = false
    users(:quentin).save!
    login_as :aaron
    assert_difference Comment, :count, 1 do
      assert_no_difference ActionMailer::Base.deliveries, :length do
        create_user_comment
      end
    end
    assert_response :redirect
  end
    
  def test_should_fail_to_create_user_comment
    login_as :aaron
    assert_no_difference Comment, :count do
      create_user_comment(:comment => {:comment => nil})
    end    
    assert_response :redirect    
  end

  def test_should_create_photo_comment
    login_as :aaron
    assert_difference Comment, :count, 1 do
      create_photo_comment
    end
    assert_response :redirect    
  end
  
  def test_should_fail_to_create_photo_comment
    login_as :aaron
    assert_no_difference Comment, :count do
      create_photo_comment(:comment => {:comment => nil})
    end    
    assert_response :redirect    
  end

  def test_should_create_post_comment
    login_as :aaron
    assert_difference Comment, :count, 1 do
      create_post_comment
    end
    assert_response :redirect    
  end
  
  def test_should_destroy_post_comment
    login_as :quentin
    assert_difference Comment, :count, -1 do
      delete :destroy, :commentable_type => 'Post', :commentable_id => comments(:quentins_comment_on_his_own_post).commentable_id, :id => comments(:quentins_comment_on_his_own_post)
    end
  end
  
  def test_should_not_destroy_post_comment
    login_as :aaron
    assert_no_difference Comment, :count do
      delete :destroy, :commentable_type => 'Post', :commentable_id => comments(:quentins_comment_on_his_own_post).commentable_id, :id => comments(:quentins_comment_on_his_own_post)
    end
  end
  
  def test_should_fail_to_create_post_comment
    login_as :aaron
    assert_no_difference Comment, :count do
      create_post_comment(:comment => {:comment => nil})
    end    
    assert_response :redirect    
  end

  def test_should_fail_to_create_comment
    login_as :aaron
    assert_raises(NameError) do 
      create_post_comment(:commentable_type => 'unkown_commentable_type')
    end
  end

  def test_should_show_comments_index
    login_as :quentin
    get :index, :commentable_type => 'user', :commentable_id => users(:aaron).to_param
    assert_response :success
    assert !assigns(:comments).empty?
  end

  def test_should_show_comments_index_rss
    login_as :quentin
    get :index, :commentable_type => 'user', :commentable_id => users(:aaron).to_param, :format => 'rss'
    assert_response :success
    assert !assigns(:comments).empty?
  end

  def test_should_show_private_comments_index_if_logged_in
    login_as :quentin
    get :index, :commentable_type => 'user', :commentable_id => users(:privateuser).to_param
    assert !assigns(:comments).empty?    
    assert_response :success
  end

  def test_should_not_show_private_comments_index
    get :index, :commentable_type => 'user', :commentable_id => users(:privateuser).to_param
    assert_response :redirect
  end
  
  def test_should_show_comments_index_rss_if_logged_in
    login_as :quentin
    get :index, :commentable_type => 'user', :commentable_id => users(:aaron).to_param, :_format => :rss
    assert !assigns(:comments).empty?
    assert_response :success
  end

  
  protected
  def create_user_comment(options = {})
    post :create, {:commentable_type => (options[:commentable_type] || "user"), 
        :commentable_id => (options[:user_id] || users(:quentin).id), 
        :comment => {:title => "test comment to quentin", :comment => "hey man, how are you?"}.merge(options[:comment] || {})
      }
  end

  def create_photo_comment(options = {})
    post :create, {:commentable_type => (options[:commentable_type] || "photo"), 
        :commentable_id => (options[:photo_id] || photos(:library_pic).id), 
        :comment => {:title => "test comment on a photo", :comment => "hey man, nice pic?"}.merge(options[:comment] || {})
      }
  end

  def create_post_comment(options = {})
    post :create, {:commentable_type => (options[:commentable_type] || "post"), 
        :commentable_id => (options[:post_id] || posts(:funny_post).id), 
        :comment => {:title => "test comment on a posts", :comment => "hey man, nice posts?"}.merge(options[:comment] || {})
      }
  end



end
