require File.dirname(__FILE__) + '/../test_helper'
require 'topics_controller'

# Re-raise errors caught by the controller.
#class TopicsController; def rescue_action(e) raise e end; end

class TopicsControllerTest < Test::Unit::TestCase
  all_fixtures

  def setup
    @controller = TopicsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index, :forum_id => 1
    assert_redirected_to forum_path(1)
  end

  def test_should_get_index_as_xml
    content_type 'application/xml'
    get :index, :forum_id => 1, :format => 'xml'
    assert_response :success
  end

  def test_should_show_topic_as_rss
    get :show, :forum_id => forums(:rails).id, :id => topics(:pdi).id, :format => 'rss'
    assert_response :success
  end
  
  def test_should_show_topic_as_xml
    content_type 'application/xml'
    get :show, :forum_id => forums(:rails).id, :id => topics(:pdi).id, :format => 'xml'
    assert_response :success
  end

  def test_should_get_new
    login_as :aaron
    get :new, :forum_id => 1
    assert_response :success
  end

  def test_sticky_and_locked_protected_from_non_admin
    login_as :joe
    assert ! users(:joe).admin?
    assert ! users(:joe).moderator_of?(:rails)
    post :create, :forum_id => forums(:rails).id, :topic => { :title => 'blah', :sticky => "1", :locked => "1", :body => 'foo' }
    assert assigns(:topic)
    assert ! assigns(:topic).sticky?
    assert ! assigns(:topic).locked?
  end

  def test_sticky_and_locked_allowed_to_moderator
    login_as :sam
    assert ! users(:sam).admin?
    assert users(:sam).moderator_of?(forums(:rails))
    post :create, :forum_id => forums(:rails).id, :topic => { :title => 'blah', :sticky => "1", :locked => "1", :body => 'foo' }
    assert assigns(:topic)
    assert assigns(:topic).sticky?
    assert assigns(:topic).locked?
  end
    
  def test_should_allow_admin_to_sticky_and_lock
    login_as :admin
    post :create, :forum_id => forums(:rails).id, :topic => { :title => 'blah2', :sticky => "1", :locked => "1", :body => 'foo' }
    assert assigns(:topic).sticky?
    assert assigns(:topic).locked?
  end

  uses_transaction :test_should_not_create_topic_without_body

  def test_should_not_create_topic_without_body
    counts = lambda { [Topic.count, SbPost.count] }
    old = counts.call
    
    login_as :aaron
    
    post :create, :forum_id => forums(:rails).id, :topic => { :title => 'blah' }
    assert assigns(:topic)
    assert assigns(:post)
    # both of these should be new records if the save fails so that the view can
    # render accordingly
    assert assigns(:topic).new_record?
    assert assigns(:post).new_record?
    
    assert_equal old, counts.call
  end

  def test_should_create_topic
    counts = lambda { [Topic.count, SbPost.count, forums(:rails).topics_count, forums(:rails).sb_posts_count,  users(:aaron).sb_posts_count] }
    old = counts.call
    
    login_as :aaron
    post :create, :forum_id => forums(:rails).id, :topic => { :title => 'blah', :body => 'foo' }
    assert assigns(:topic)
    assert assigns(:post)
    assert_redirected_to forum_topic_path(forums(:rails), assigns(:topic))
    [forums(:rails), users(:aaron)].each &:reload
  
    assert_equal old.collect { |n| n + 1}, counts.call
  end

  # def test_should_create_topic_with_xml
  #   content_type 'application/xml'
  #   authorize_as :aaron
  #   post :create, :forum_id => forums(:rails).id, :topic => { :title => 'blah', :body => 'foo' }, :format => 'xml'
  #   assert_response :created
  #   assert_equal formatted_forum_topic_url(:forum_id => forums(:rails), :id => assigns(:topic), :format => :xml), @response.headers["Location"]
  # end

  def test_should_delete_topic
    counts = lambda { [SbPost.count, forums(:rails).topics_count, forums(:rails).sb_posts_count] }
    old = counts.call
    
    login_as :admin
    delete :destroy, :forum_id => forums(:rails).id, :id => topics(:ponies).id
    assert_redirected_to forum_path(forums(:rails))
    [forums(:rails), users(:aaron)].each &:reload

    assert_equal old.collect { |n| n - 1}, counts.call
  end

  # def test_should_delete_topic_with_xml
  #   content_type 'application/xml'
  #   authorize_as :aaron
  #   delete :destroy, :forum_id => forums(:rails).id, :id => topics(:ponies).id, :format => 'xml'
  #   assert_response :success
  # end

  def test_should_allow_moderator_to_delete_topic
    assert_difference Topic, :count, -1 do
      login_as :sam
      delete :destroy, :forum_id => forums(:rails).id, :id => topics(:pdi).id
    end
  end

  def test_should_update_views_for_show
    assert_difference topics(:pdi), :views do
      get :show, :forum_id => forums(:rails).id, :id => topics(:pdi).id
      assert_response :success
      topics(:pdi).reload
    end
  end

  def test_should_not_update_views_for_show_via_rss
    assert_difference topics(:pdi), :views, 0 do
      get :show, :forum_id => forums(:rails).id, :id => topics(:pdi).id, :format => 'rss'
      assert_response :success
      topics(:pdi).reload
    end
  end

  def test_should_not_add_viewed_topic_to_session_on_show_rss
    login_as :aaron
    get :show, :forum_id => forums(:rails).id, :id => topics(:pdi).id, :format => 'rss'
    assert_response :success
    assert session[:topics].blank?
  end

  def test_should_update_views_for_show_except_topic_author
    login_as :aaron
    views=topics(:pdi).views
    get :show, :forum_id => forums(:rails).id, :id => topics(:pdi).id
    assert_response :success
    assert_equal views, topics(:pdi).reload.views
  end

  def test_should_show_topic
    get :show, :forum_id => forums(:rails).id, :id => topics(:pdi).id
    assert_response :success
    assert_equal topics(:pdi), assigns(:topic)
    assert_models_equal [sb_posts(:pdi), sb_posts(:pdi_reply), sb_posts(:pdi_rebuttal)], assigns(:posts)
  end

  def test_should_show_other_post
    get :show, :forum_id => forums(:rails).id, :id => topics(:ponies).id
    assert_response :success
    assert_equal topics(:ponies), assigns(:topic)
    assert_models_equal [sb_posts(:ponies)], assigns(:posts)
  end

  def test_should_get_edit
    login_as :admin
    get :edit, :forum_id => 1, :id => 1
    assert_response :success
  end
  
  def test_should_update_own_post
    login_as :sam
    put :update, :forum_id => forums(:rails).id, :id => topics(:ponies).id, :topic => { }
    assert_redirected_to forum_topic_path(forums(:rails), assigns(:topic))
  end

  # def test_should_update_with_xml
  #   content_type 'application/xml'
  #   authorize_as :sam
  #   put :update, :forum_id => forums(:rails).id, :id => topics(:ponies).id, :topic => { }, :format => 'xml'
  #   assert_response :success
  # end

  def test_should_not_update_user_id_of_own_post
    login_as :sam
    put :update, :forum_id => forums(:rails).id, :id => topics(:ponies).id, :topic => { :user_id => 32 }
    assert_redirected_to forum_topic_path(forums(:rails), assigns(:topic))
    assert_equal users(:sam).id, sb_posts(:ponies).reload.user_id
  end

  def test_should_not_update_other_post
    login_as :sam
    put :update, :forum_id => forums(:comics).id, :id => topics(:galactus).id, :topic => { }
    assert_redirected_to login_path
  end

  # def test_should_not_update_other_post_with_xml
  #   content_type 'application/xml'
  #   authorize_as :sam
  #   put :update, :forum_id => forums(:comics).id, :id => topics(:galactus).id, :topic => { }, :format => 'xml'
  #   assert_response :unauthorized
  # end

  def test_should_update_other_post_as_moderator
    login_as :sam
    put :update, :forum_id => forums(:rails).id, :id => topics(:pdi).id, :topic => { }
    assert_redirected_to forum_topic_path(forums(:rails), assigns(:topic))
  end

  def test_should_update_other_post_as_admin
    login_as :admin
    put :update, :forum_id => forums(:rails).id, :id => topics(:ponies), :topic => { }
    assert_redirected_to forum_topic_path(forums(:rails), assigns(:topic))
  end
end
