require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  fixtures :users, :photos, :posts, :comments, :roles

  def test_should_create_user_comment
    login_as :aaron
    assert_difference Comment, :count, 1 do
        create_user_comment
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
    get :index, :commentable_type => 'users', :commentable_id => users(:aaron).to_param
    assert_response :success
    assert !assigns(:comments).empty?
  end

  def test_should_show_comments_index_rss
    login_as :quentin
    get :index, :commentable_type => 'users', :commentable_id => users(:aaron).to_param, :format => 'rss'
    assert_response :success
    assert !assigns(:comments).empty?
  end

  def test_should_show_empty_comments_index
    login_as :aaron
    get :index, :commentable_type => 'users', :commentable_id => users(:quentin).to_param
    assert_response :success
    assert assigns(:comments).empty?
  end

  def test_should_show_empty_comments_index_rss
    login_as :aaron
    get :index, :commentable_type => 'users', :commentable_id => users(:quentin).to_param, :format => 'rss'
    assert_response :success
    assert assigns(:comments).empty?
  end

  def test_should_show_private_comments_index_if_logged_in
    login_as :quentin
    get :index, :commentable_type => 'users', :commentable_id => users(:privateuser).to_param
    assert !assigns(:comments).empty?
    assert_response :success
  end

  def test_should_not_show_private_comments_index
    get :index, :commentable_type => 'users', :commentable_id => users(:privateuser).to_param
    assert_response :redirect
  end

  def test_should_show_comments_index_rss_if_logged_in
    login_as :quentin
    get :index, :commentable_type => 'users', :commentable_id => users(:aaron).to_param, :format => 'rss'
    assert !assigns(:comments).empty?
    assert_response :success
  end

  def test_should_unsubscribe_with_token
    configatron.temp do
      configatron.allow_anonymous_commenting = true
      comment = Comment.create!(:comment => 'foo', :author_email => 'bar@foo.com', :author_ip => '123.123.123', :recipient => users(:quentin), :commentable => users(:quentin), :notify_by_email => true)
      configatron.allow_anonymous_commenting = false

      get :unsubscribe, :commentable_type => comment.commentable_type, :commentable_id => comment.commentable_id, :id => comment.id, :token => comment.token_for('bar@foo.com'), :email => 'bar@foo.com'
      assert comment.reload.notify_by_email.eql?(false)
    end
  end

  def test_should_not_unsubscribe_with_bad_token
    configatron.temp do
      configatron.allow_anonymous_commenting = true
      comment = Comment.create!(:comment => 'foo', :author_email => 'bar@foo.com', :author_ip => '123.123.123', :recipient => users(:quentin), :commentable => users(:quentin), :notify_by_email => true)
      configatron.allow_anonymous_commenting = false

      get :unsubscribe, :commentable_type => 'User', :commentable_id => users(:quentin).to_param, :id => comment.id, :token => 'badtokengoeshere'
      assert comment.reload.notify_by_email.eql?(true)
    end
  end

  def test_should_get_edit_js_as_admin
    login_as :admin
    get :edit, :id => comments(:quentins_comment_on_his_own_post), :format => 'js'
    assert_response :success
  end

  def test_should_update_as_admin
    login_as :admin
    edited_text = 'edited the comment body'
    patch :update, :id => comments(:quentins_comment_on_his_own_post), :comment => {:comment => edited_text}, :format => 'js'
    
    assert assigns(:comment).comment.eql?(edited_text)
    assert_response :success
  end

  def test_should_not_update_if_not_admin_or_moderator
    login_as :quentin
    
    edited_text = 'edited the comment body'    
    patch :update, :id => comments(:quentins_comment_on_his_own_post), :comment => {:comment => edited_text}, :format => "js"
    
    assert_response :success #js redirect
    assert_not_equal(comments(:quentins_comment_on_his_own_post).comment, edited_text)
  end



  protected

  def create_user_comment(options = {})
    post :create, {:commentable_type => (options[:commentable_type] || "users"),
        :commentable_id => (options[:user_id] || users(:quentin).id),
        :comment => {:title => "test comment to quentin", :comment => "hey man, how are you?"}.merge(options[:comment] || {})
      }
  end

  def create_photo_comment(options = {})
    post :create, {:commentable_type => (options[:commentable_type] || "photos"),
        :commentable_id => (options[:photo_id] || photos(:library_pic).id),
        :comment => {:title => "test comment on a photo", :comment => "hey man, nice pic?"}.merge(options[:comment] || {})
      }
  end

  def create_post_comment(options = {})
    post :create, {:commentable_type => (options[:commentable_type] || "posts"),
        :commentable_id => (options[:post_id] || posts(:funny_post).id),
        :comment => {:title => "test comment on a posts", :comment => "hey man, nice posts?"}.merge(options[:comment] || {})
      }
  end



end
