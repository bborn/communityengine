require File.dirname(__FILE__) + '/../test_helper'

class SbPostTest < ActiveSupport::TestCase
  all_fixtures
  include ActionDispatch::TestProcess

    def test_should_find_topic
    assert_equal topics(:pdi), sb_posts(:pdi_reply).topic
  end

  def test_should_require_body_for_post
    p = topics(:pdi).sb_posts.build
    p.valid?
    assert p.errors[:body]
  end

  def test_should_create_reply
    counts = lambda { [SbPost.count, forums(:rails).sb_posts_count, users(:aaron).sb_posts_count, topics(:pdi).sb_posts_count] }
    equal  = lambda { [forums(:rails).topics_count] }
    old_counts = counts.call
    old_equal  = equal.call
    
    p = create_post topics(:pdi), :body => 'blah'
    assert p.valid?

    [forums(:rails), users(:aaron), topics(:pdi)].each &:reload
    
    assert_equal old_counts.collect { |n| n + 1}, counts.call
    assert_equal old_equal, equal.call
  end

  def test_should_update_cached_data
    p = create_post topics(:pdi), :body => 'ok, ill get right on it'
    assert p.valid?
    topics(:pdi).reload
    assert_equal p.id, topics(:pdi).last_post_id
    assert_equal p.user_id, topics(:pdi).replied_by
    assert_equal p.created_at.to_i, topics(:pdi).replied_at.to_i
  end

  def test_should_delete_last_post_and_fix_topic_cached_data
    sb_posts(:pdi_rebuttal).destroy
    assert_equal sb_posts(:pdi_reply).id, topics(:pdi).last_post_id
    assert_equal sb_posts(:pdi_reply).user_id, topics(:pdi).replied_by
    assert_equal sb_posts(:pdi_reply).created_at.to_i, topics(:pdi).replied_at.to_i
  end

  def test_should_create_reply_and_set_forum_from_topic
    p = create_post topics(:pdi), :body => 'blah'
    assert_equal topics(:pdi).forum_id, p.forum_id
  end

  def test_should_delete_reply
    counts = lambda { [SbPost.count, forums(:rails).sb_posts_count, users(:sam).sb_posts_count, topics(:pdi).sb_posts_count] }
    equal  = lambda { [forums(:rails).topics_count] }
    old_counts = counts.call
    old_equal  = equal.call
    sb_posts(:pdi_reply).destroy
    [forums(:rails), users(:sam), topics(:pdi)].each &:reload
    assert_equal old_counts.collect { |n| n - 1}, counts.call
    assert_equal old_equal, equal.call
  end

  def test_should_edit_own_post
    assert sb_posts(:shield).editable_by?(users(:sam))
  end

  def test_should_edit_post_as_admin
    assert sb_posts(:shield).editable_by?(users(:admin))
  end

  def test_should_edit_post_as_moderator
    assert sb_posts(:pdi).editable_by?(users(:sam))
  end

  def test_should_not_edit_post_in_own_topic
    assert !sb_posts(:shield_reply).editable_by?(users(:sam))
  end
  
  def test_should_automatically_monitor_after_creating
    topic  = topics(:ponies)
    assert !users(:aaron).monitoring_topic?(topic)
    p = create_post topic, :body => 'blah'
    assert users(:aaron).monitoring_topic?(topic)
  end
  
  def test_should_not_monitor_if_already_unmonitored
    topic = topics(:pdi)
    user = users(:aaron) 
    create_post topic, :body => 'foo'      
    Monitorship.update_all ['active = ?', false], ['user_id = ? and topic_id = ?', user.id, topic.id]            
    assert !user.monitoring_topic?(topic)
    
    p = create_post topic, :body => 'bar'
    assert !user.monitoring_topic?(topic)    
  end
  
  test "should not monitor for anonymous posts" do
    configatron.allow_anonymous_forum_posting = true
    
    assert_difference Monitorship, :count, 0 do
      topic = topics(:pdi)
      topic.sb_posts.create!(:topic => topic, :body => "Ok!", :author_email => 'anon@example.com', :author_ip => "1.2.3.4")      
    end
    
    configatron.allow_anonymous_forum_posting = false    
  end
  
  def test_to_xml
    #not really testing the output cause it's just calling Rails' to_xml
    assert sb_posts(:shield_reply).to_xml
  end
  
  def test_should_be_deleted_when_user_destroyed
    post = sb_posts(:shield_reply)
    id = post.id
    post.user.destroy
    assert !SbPost.exists?(id)
  end

  test "should not allow anonymous posting" do
    configatron.allow_anonymous_forum_posting = false    
    topic = topics(:pdi)      
    post = topic.sb_posts.create(:topic => topic, :body => "Ok!", :author_email => 'anon@example.com', :author_ip => "1.2.3.4")
    assert !post.valid?
    assert post.errors[:user_id]
  end
  
  test "should allow anonymous posting if configatron specifies it's ok" do
    configatron.allow_anonymous_forum_posting = true
    
    topic = topics(:pdi)
      
    assert topic.sb_posts.create!(:topic => topic, :body => "Ok!", :author_email => 'anon@example.com', :author_ip => "1.2.3.4")
    
    configatron.allow_anonymous_forum_posting = false    
  end
  
  protected
    def create_post(topic, options = {})
      returning topic.sb_posts.new(options) do |p|
        p.user = users(:aaron)
        p.save!
      end
    end
end
