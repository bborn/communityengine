require 'test_helper'

class SbPostsControllerTest < ActionController::TestCase
  all_fixtures

  def test_should_create_reply
    counts = lambda { [SbPost.count, forums(:rails).sb_posts_count, users(:aaron).sb_posts_count, topics(:pdi).sb_posts_count] }
    equal  = lambda { [forums(:rails).topics_count] }
    old_counts = counts.call
    old_equal  = equal.call

    login_as :aaron
    post :create, :forum_id => forums(:rails).to_param, :topic_id => topics(:pdi).to_param, :post => { :body => 'blah' }
    assert_redirected_to forum_topic_path(:forum_id => forums(:rails).to_param, :id => topics(:pdi).to_param, :anchor => assigns(:post).dom_id, :page => '1')
    assert_equal topics(:pdi), assigns(:topic)
    [forums(:rails), users(:aaron), topics(:pdi)].each &:reload
  
    assert_equal old_counts.collect { |n| n + 1}, counts.call
    assert_equal old_equal, equal.call
  end

  def test_should_update_topic_replied_at_upon_replying
    old=topics(:pdi).replied_at
    login_as :aaron
    post :create, :forum_id => forums(:rails).to_param, :topic_id => topics(:pdi).to_param, :post => { :body => 'blah' }
    assert_not_equal(old, topics(:pdi).reload.replied_at)
    assert old < topics(:pdi).reload.replied_at
  end

  def test_should_reply_with_no_body
    assert_difference SbPost, :count, 0 do
      login_as :aaron
      post :create, :forum_id => forums(:rails).to_param, :topic_id => sb_posts(:pdi).to_param, :post => {:body => ''}
      assert_redirected_to forum_topic_path({:forum_id => forums(:rails).to_param, :id => sb_posts(:pdi).to_param, :anchor => 'reply-form', :page => '1'}.merge(:post => {:body => ''}))
    end
  end

  def test_should_delete_reply
    counts = lambda { [SbPost.count, forums(:rails).sb_posts_count, users(:sam).sb_posts_count, topics(:pdi).sb_posts_count] }
    equal  = lambda { [forums(:rails).topics_count] }
    old_counts = counts.call
    old_equal  = equal.call

    login_as :admin
    delete :destroy, :forum_id => forums(:rails).to_param, :topic_id => topics(:pdi).to_param, :id => sb_posts(:pdi_reply).to_param
    assert_redirected_to forum_topic_path(:forum_id => forums(:rails).to_param, :id => topics(:pdi).to_param)

    [forums(:rails), users(:sam), topics(:pdi)].each &:reload

    assert_equal old_counts.collect { |n| n - 1}, counts.call
    assert_equal old_equal, equal.call
  end

  def test_should_delete_reply_as_moderator
    assert_difference SbPost, :count, -1 do
      login_as :sam
      delete :destroy, :forum_id => forums(:rails).to_param, :topic_id => topics(:pdi).to_param, :id => sb_posts(:pdi_rebuttal).to_param
    end
  end

  def test_should_delete_topic_if_deleting_the_last_reply
    assert_difference SbPost, :count, -1 do
      assert_difference Topic, :count, -1 do
        login_as :aaron
        delete :destroy, :forum_id => forums(:rails).to_param, :topic_id => topics(:il8n).to_param, :id => sb_posts(:il8n).to_param
        assert_redirected_to forum_path(forums(:rails).to_param)
        assert_raise(ActiveRecord::RecordNotFound) { topics(:il8n).reload }
      end
    end
  end

  def test_edit_js
    login_as :sam
    get :edit, :forum_id => forums(:comics).to_param, :topic_id => topics(:galactus).to_param, :id => sb_posts(:silver_surfer).to_param, :format => 'js'
    assert_response :success
  end

  def test_can_edit_own_post
    login_as :sam
    put :update, :forum_id => forums(:comics).to_param, :topic_id => topics(:galactus).to_param, :id => sb_posts(:silver_surfer).to_param, :post => {}
    assert_redirected_to forum_topic_path(:forum_id => forums(:comics).to_param, :id => topics(:galactus).to_param, :anchor => sb_posts(:silver_surfer).dom_id, :page => '1')
  end

  def test_can_edit_other_post_as_moderator
    login_as :sam
    put :update, :forum_id => forums(:rails).to_param, :topic_id => topics(:pdi).to_param, :id => sb_posts(:pdi_rebuttal).to_param, :post => {}
    assert_redirected_to forum_topic_path(:forum_id => forums(:rails).to_param, :id => topics(:pdi).to_param, :anchor => sb_posts(:pdi_rebuttal).dom_id, :page => '1')
  end

  def test_cannot_edit_other_post
    login_as :sam
    put :update, :forum_id => forums(:comics).to_param, :topic_id => topics(:galactus).to_param, :id => sb_posts(:galactus).to_param, :post => {}
    assert_redirected_to login_path
  end

  def test_cannot_edit_own_post_user_id
    login_as :sam
    put :update, :forum_id => forums(:rails).to_param, :topic_id => topics(:pdi).to_param, :id => sb_posts(:pdi_reply).to_param, :post => { :user_id => 32 }
    assert_redirected_to forum_topic_path(:forum_id => forums(:rails).to_param, :id => topics(:pdi).to_param, :anchor => sb_posts(:pdi_reply).dom_id, :page => '1')
    assert_equal users(:sam).id, sb_posts(:pdi_reply).reload.user_id
  end

  def test_can_edit_other_post_as_admin
    login_as :admin
    put :update, :forum_id => forums(:rails).to_param, :topic_id => topics(:pdi).to_param, :id => sb_posts(:pdi_rebuttal).to_param, :post => {}
    assert_redirected_to forum_topic_path(:forum_id => forums(:rails).to_param, :id => topics(:pdi).to_param, :anchor => sb_posts(:pdi_rebuttal).dom_id, :page => '1')
  end
  
  def test_should_view_recent_posts
    get :index
    assert_response :success
    assert_equal [sb_posts(:il8n), sb_posts(:shield_reply), sb_posts(:shield), sb_posts(:silver_surfer), sb_posts(:galactus), sb_posts(:ponies), sb_posts(:pdi_rebuttal), sb_posts(:pdi_reply), sb_posts(:pdi), sb_posts(:sticky)], assigns(:posts)
  end

  def test_should_view_posts_by_forum
    get :index, :forum_id => forums(:comics).to_param
    assert_response :success
    assert_equal [sb_posts(:shield_reply), sb_posts(:shield), sb_posts(:silver_surfer), sb_posts(:galactus)], assigns(:posts)
  end

  def test_should_view_posts_by_user
    get :index, :user_id => users(:sam).id
    assert_response :success
    assert_equal [sb_posts(:shield), sb_posts(:silver_surfer), sb_posts(:ponies), sb_posts(:pdi_reply), sb_posts(:sticky)], assigns(:posts)
  end
  
  def test_should_view_monitored_posts
    get :monitored, :user_id => users(:aaron).id
    assert_equal [sb_posts(:pdi_reply)], assigns(:posts)
  end

  def test_should_search_recent_posts
    get :search, :q => 'pdi'
    assert_response :success
    assert_equal [sb_posts(:pdi_rebuttal), sb_posts(:pdi_reply), sb_posts(:pdi)], assigns(:posts)
  end

  def test_should_search_posts_by_forum
    get :search, :forum_id => forums(:comics).to_param, :q => 'galactus'
    assert_response :success
    assert_equal [sb_posts(:silver_surfer), sb_posts(:galactus)], assigns(:posts)
  end
    
  def test_disallow_new_post_to_locked_topic
    galactus = topics(:galactus)
    galactus.locked = true
    galactus.save!
    login_as :aaron
    post :create, :forum_id => forums(:comics).to_param, :topic_id => topics(:galactus).to_param, :post => { :body => 'blah' }
    assert_redirected_to forum_topic_path(forums(:comics).to_param, topics(:galactus).to_param)
    assert_equal :this_topic_is_locked.l, flash[:notice]
  end
  
  
  test "should create anonymous reply" do
    configatron.allow_anonymous_forum_posting = true    
    assert_difference SbPost, :count, 1 do
      post :create, :forum_id => forums(:rails).to_param, :topic_id => topics(:pdi).to_param, :post => { :body => 'blah', :author_email => 'foo@bar.com' }
      assert_redirected_to :controller => "topics", :action => "show", :forum_id => forums(:rails).to_param, :id => topics(:pdi).to_param, :anchor => assigns(:post).dom_id, :page => '1'
    end
    configatron.allow_anonymous_forum_posting = false    
  end

  test "should fail creating an anonymous reply" do
    configatron.allow_anonymous_forum_posting = true        
    assert_difference SbPost, :count, 0 do
      post_params = { :body => 'blah', :author_email => 'foo' }
      post :create, :forum_id => forums(:rails).to_param, :topic_id => topics(:pdi).to_param, :post => post_params
      assert_redirected_to forum_topic_path({:forum_id => forums(:rails).to_param, :id => topics(:pdi).to_param, :anchor => 'reply-form', :page => '1'}.merge({:post => post_params}))
    end
    configatron.allow_anonymous_forum_posting = false        
  end

  test "should show recent with anonymous posts" do
    configatron.allow_anonymous_forum_posting = true
    
    topic = topics(:pdi)
      
    assert topic.sb_posts.create!(:topic => topic, :body => "Ok!", :author_email => 'anon@example.com', :author_ip => "1.2.3.4")
    
    get :index    
    assert_response :success
    
    configatron.allow_anonymous_forum_posting = false        
  end
  

  
end
