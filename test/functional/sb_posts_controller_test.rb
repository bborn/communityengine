require File.dirname(__FILE__) + '/../test_helper'
require 'sb_posts_controller'

# Re-raise errors caught by the controller.
class SbPostsController; def rescue_action(e) raise e end; end

class SbPostsControllerTest < Test::Unit::TestCase
  all_fixtures
  def setup
    @controller = SbPostsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_create_reply
    counts = lambda { [SbPost.count, forums(:rails).sb_posts_count, users(:aaron).sb_posts_count, topics(:pdi).sb_posts_count] }
    equal  = lambda { [forums(:rails).topics_count] }
    old_counts = counts.call
    old_equal  = equal.call

    login_as :aaron
    post :create, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :post => { :body => 'blah' }
    assert_redirected_to forum_topic_path(:forum_id => forums(:rails).id, :id => topics(:pdi).id, :anchor => assigns(:post).dom_id, :page => '1')
    assert_equal topics(:pdi), assigns(:topic)
    [forums(:rails), users(:aaron), topics(:pdi)].each &:reload
  
    assert_equal old_counts.collect { |n| n + 1}, counts.call
    assert_equal old_equal, equal.call
  end

  # def test_should_create_reply_with_xml
  #   content_type 'application/xml'
  #   authorize_as :aaron
  #   post :create, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :post => { :body => 'blah' }, :format => 'xml'
  #   assert_response :created
  #   assert_equal formatted_sb_user_post_url(:forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => assigns(:post), :format => :xml), @response.headers["Location"]
  # end

  def test_should_update_topic_replied_at_upon_replying
    old=topics(:pdi).replied_at
    login_as :aaron
    post :create, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :post => { :body => 'blah' }
    assert_not_equal(old, topics(:pdi).reload.replied_at)
    assert old < topics(:pdi).reload.replied_at
  end

  def test_should_reply_with_no_body
    assert_difference SbPost, :count, 0 do
      login_as :aaron
      post :create, :forum_id => forums(:rails).id, :topic_id => sb_posts(:pdi).id, :post => {}
      assert_redirected_to forum_topic_path(:forum_id => forums(:rails).id, :id => sb_posts(:pdi).id, :anchor => 'reply-form', :page => '1')
    end
  end

  def test_should_delete_reply
    counts = lambda { [SbPost.count, forums(:rails).sb_posts_count, users(:sam).sb_posts_count, topics(:pdi).sb_posts_count] }
    equal  = lambda { [forums(:rails).topics_count] }
    old_counts = counts.call
    old_equal  = equal.call

    login_as :admin
    delete :destroy, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => sb_posts(:pdi_reply).id
    assert_redirected_to forum_topic_path(:forum_id => forums(:rails).id, :id => topics(:pdi).id)

    [forums(:rails), users(:sam), topics(:pdi)].each &:reload

    assert_equal old_counts.collect { |n| n - 1}, counts.call
    assert_equal old_equal, equal.call
  end

  # def test_should_delete_reply_with_xml
  #   content_type 'application/xml'
  #   authorize_as :aaron
  #   delete :destroy, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => sb_posts(:pdi_reply).id, :format => 'xml'
  #   assert_response :success
  # end

  def test_should_delete_reply_as_moderator
    assert_difference SbPost, :count, -1 do
      login_as :sam
      delete :destroy, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => sb_posts(:pdi_rebuttal).id
    end
  end

  def test_should_delete_topic_if_deleting_the_last_reply
    assert_difference SbPost, :count, -1 do
      assert_difference Topic, :count, -1 do
        login_as :aaron
        delete :destroy, :forum_id => forums(:rails).id, :topic_id => topics(:il8n).id, :id => sb_posts(:il8n).id
        assert_redirected_to forum_path(forums(:rails).id)
        assert_raise(ActiveRecord::RecordNotFound) { topics(:il8n).reload }
      end
    end
  end

  def test_edit_js
    login_as :sam
    get :edit, :forum_id => forums(:comics).id, :topic_id => topics(:galactus).id, :id => sb_posts(:silver_surfer).id, :format => 'js'
    assert_response :success
  end

  def test_can_edit_own_post
    login_as :sam
    put :update, :forum_id => forums(:comics).id, :topic_id => topics(:galactus).id, :id => sb_posts(:silver_surfer).id, :post => {}
    assert_redirected_to forum_topic_path(:forum_id => forums(:comics).id, :id => topics(:galactus).id, :anchor => sb_posts(:silver_surfer).dom_id, :page => '1')
  end

  # def test_can_edit_own_post_with_xml
  #   content_type 'application/xml'
  #   authorize_as :sam
  #   put :update, :forum_id => forums(:comics).id, :topic_id => topics(:galactus).id, :id => sb_posts(:silver_surfer).id, :post => {}, :format => 'xml'
  #   assert_response :success
  # end


  def test_can_edit_other_post_as_moderator
    login_as :sam
    put :update, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => sb_posts(:pdi_rebuttal), :post => {}
    assert_redirected_to forum_topic_path(:forum_id => forums(:rails).id, :id => topics(:pdi).id, :anchor => sb_posts(:pdi_rebuttal).dom_id, :page => '1')
  end

  def test_cannot_edit_other_post
    login_as :sam
    put :update, :forum_id => forums(:comics).id, :topic_id => topics(:galactus).id, :id => sb_posts(:galactus).id, :post => {}
    assert_redirected_to login_path
  end

  # def test_cannot_edit_other_post_with_xml
  #   content_type 'application/xml'
  #   authorize_as :sam
  #   put :update, :forum_id => forums(:comics).id, :topic_id => topics(:galactus).id, :id => sb_posts(:galactus).id, :post => {}, :format => 'xml'
  #   assert_response 401
  # end

  def test_cannot_edit_own_post_user_id
    login_as :sam
    put :update, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => sb_posts(:pdi_reply).id, :post => { :user_id => 32 }
    assert_redirected_to forum_topic_path(:forum_id => forums(:rails).id, :id => topics(:pdi).id, :anchor => sb_posts(:pdi_reply).dom_id, :page => '1')
    assert_equal users(:sam).id, sb_posts(:pdi_reply).reload.user_id
  end

  def test_can_edit_other_post_as_admin
    login_as :admin
    put :update, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => sb_posts(:pdi_rebuttal).id, :post => {}
    assert_redirected_to forum_topic_path(:forum_id => forums(:rails).id, :id => topics(:pdi).id, :anchor => sb_posts(:pdi_rebuttal).dom_id, :page => '1')
  end
  
  # def test_should_view_post_as_xml
  #   get :show, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => sb_posts(:pdi_rebuttal).id, :format => 'xml'
  #   assert_response :success
  #   assert_select 'post'
  # end
  
  def test_should_view_recent_posts
    get :index
    assert_response :success
    assert_models_equal [sb_posts(:il8n), sb_posts(:shield_reply), sb_posts(:shield), sb_posts(:silver_surfer), sb_posts(:galactus), sb_posts(:ponies), sb_posts(:pdi_rebuttal), sb_posts(:pdi_reply), sb_posts(:pdi), sb_posts(:sticky)], assigns(:posts)
  end

  def test_should_view_posts_by_forum
    get :index, :forum_id => forums(:comics).id
    assert_response :success
    assert_models_equal [sb_posts(:shield_reply), sb_posts(:shield), sb_posts(:silver_surfer), sb_posts(:galactus)], assigns(:posts)
  end

  def test_should_view_posts_by_user
    get :index, :user_id => users(:sam).id
    assert_response :success
    assert_models_equal [sb_posts(:shield), sb_posts(:silver_surfer), sb_posts(:ponies), sb_posts(:pdi_reply), sb_posts(:sticky)], assigns(:posts)
  end

  # def test_should_view_recent_posts_with_xml
  #   content_type 'application/xml'
  #   get :index, :format => 'xml'
  #   assert_response :success
  #   assert_models_equal [sb_posts(:il8n), sb_posts(:shield_reply), sb_posts(:shield), sb_posts(:silver_surfer), sb_posts(:galactus), sb_posts(:ponies), sb_posts(:pdi_rebuttal), sb_posts(:pdi_reply), sb_posts(:pdi), sb_posts(:sticky)], assigns(:posts)
  #   assert_select 'posts>post'
  # end

  # def test_should_view_posts_by_forum_with_xml
  #   content_type 'application/xml'
  #   get :index, :forum_id => forums(:comics).id, :format => 'xml'
  #   assert_response :success
  #   assert_models_equal [sb_posts(:shield_reply), sb_posts(:shield), sb_posts(:silver_surfer), sb_posts(:galactus)], assigns(:posts)
  #   assert_select 'posts>post'
  # end

  # def test_should_view_posts_by_user_with_xml
  #   content_type 'application/xml'
  #   get :index, :user_id => users(:sam).id, :format => 'xml'
  #   assert_response :success
  #   assert_models_equal [sb_posts(:shield), sb_posts(:silver_surfer), sb_posts(:ponies), sb_posts(:pdi_reply), sb_posts(:sticky)], assigns(:posts)
  #   assert_select 'posts>post'
  # end

  def test_should_view_monitored_posts
    get :monitored, :user_id => users(:aaron).id
    assert_models_equal [sb_posts(:pdi_reply)], assigns(:posts)
  end

  def test_should_search_recent_posts
    get :search, :q => 'pdi'
    assert_response :success
    assert_models_equal [sb_posts(:pdi_rebuttal), sb_posts(:pdi_reply), sb_posts(:pdi)], assigns(:posts)
  end

  def test_should_search_posts_by_forum
    get :search, :forum_id => forums(:comics).id, :q => 'galactus'
    assert_response :success
    assert_models_equal [sb_posts(:silver_surfer), sb_posts(:galactus)], assigns(:posts)
  end
  
  def test_should_view_recent_posts_as_rss
    get :index, :format => 'rss'
    assert_response :success
    assert_models_equal [sb_posts(:il8n), sb_posts(:shield_reply), sb_posts(:shield), sb_posts(:silver_surfer), sb_posts(:galactus), sb_posts(:ponies), sb_posts(:pdi_rebuttal), sb_posts(:pdi_reply), sb_posts(:pdi), sb_posts(:sticky)], assigns(:posts)
  end

  def test_should_view_posts_by_forum_as_rss
    get :index, :forum_id => forums(:comics).id, :format => 'rss'
    assert_response :success
    assert_models_equal [sb_posts(:shield_reply), sb_posts(:shield), sb_posts(:silver_surfer), sb_posts(:galactus)], assigns(:posts)
  end

  def test_should_view_posts_by_user_as_rss
    get :index, :user_id => users(:sam).id, :format => 'rss'
    assert_response :success
    assert_models_equal [sb_posts(:shield), sb_posts(:silver_surfer), sb_posts(:ponies), sb_posts(:pdi_reply), sb_posts(:sticky)], assigns(:posts)
  end
  
  def test_disallow_new_post_to_locked_topic
    galactus = topics(:galactus)
    galactus.locked = 1
    galactus.save
    login_as :aaron
    post :create, :forum_id => forums(:comics).id, :topic_id => topics(:galactus).id, :post => { :body => 'blah' }
    assert_redirected_to forum_topic_path(:forum_id => forums(:comics).id, :id => topics(:galactus).id)
    assert_equal 'This topic is locked.', flash[:notice]
  end
end
