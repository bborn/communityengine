require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  fixtures :all

  def test_save_should_update_post_id_for_posts_belonging_to_topic
    # checking current forum_id's are in sync
    topic = topics(:pdi)
    post_forums = lambda do
      topic.sb_posts.each { |p| assert_equal p.forum_id, topic.forum_id }
    end
    post_forums.call
    assert_equal forums(:rails).id, topic.forum_id
    
    # updating forum_id
    topic.update_attribute :forum_id, forums(:comics).id
    assert_equal forums(:comics).id, topic.reload.forum_id
    post_forums.call
  end

  def test_knows_last_post
    assert_equal sb_posts(:pdi_rebuttal), topics(:pdi).sb_posts.recent.last
  end
  
  def test_should_add_to_user_counter_cache
    assert_difference SbPost, :count do
      assert_difference users(:sam).sb_posts, :count do
        p = topics(:galactus).sb_posts.new(:body => "I'll do it")
        p.user = users(:sam)
        p.save
      end
    end
  end
 
  def test_should_create_topic
    counts = lambda { [Topic.count, forums(:rails).topics_count] }
    old = counts.call
    t = forums(:rails).topics.new(:title => 'foo')
    t.user = users(:aaron)
    assert t.valid?
    t.save
    assert_equal 0, t.sticky
    [forums(:rails), users(:aaron)].each &:reload
    assert_equal old.collect { |n| n + 1}, counts.call
  end
  
  def test_should_delete_topic
    counts = lambda { [Topic.count, SbPost.count, forums(:rails).topics_count, forums(:rails).sb_posts_count,  users(:sam).sb_posts_count] }
    old = counts.call
    topics(:ponies).destroy
    [forums(:rails), users(:sam)].each &:reload
    assert_equal old.collect { |n| n - 1}, counts.call
  end
  
  def test_hits
    hits=topics(:pdi).views
    topics(:pdi).hit!
    topics(:pdi).hit!
    assert_equal(topics(:pdi).hits, topics(:pdi).views)      
    assert_equal(hits+2, topics(:pdi).reload.hits)
  end
  
  def test_replied_at_set
    t=Topic.new
    t.user=users(:aaron)
    t.title = "happy life"
    t.forum = forums(:rails)
    assert t.save
    assert_not_nil t.replied_at
    assert t.replied_at <= Time.now.utc
    assert_in_delta t.replied_at, Time.now.utc, 5.seconds
  end
  
  def test_doesnt_change_replied_at_on_save
    t=Topic.find(:first)
    old=t.replied_at
    assert t.save
    assert_equal old, t.replied_at
  end

  def test_notify_of_new_post
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      # aaron and sam are monitoring, but aaron's the author, so just one notification
      topics(:pdi).notify_of_new_post( topics(:pdi).sb_posts.last )
    end
  end

  test "should notify for new anonymous post" do
    configatron.allow_anonymous_forum_posting = true
    assert_difference ActionMailer::Base.deliveries, :length, 2 do
      post = topics(:pdi).sb_posts.create!(:body => "Anonymous post", :author_email => 'foo@bar.com', :author_ip => '1.2.3.4')
    end    
    configatron.allow_anonymous_forum_posting = false
  end
  
  def test_topic_creator_should_monitor_automatically
    t = forums(:rails).topics.new(:title => 'foo')
    t.user = users(:aaron)
    t.save  
    assert users(:aaron).monitoring_topic?(t)
  end
  
  def test_should_be_deleted_when_user_destroyed
    topic = topics(:ponies)
    id = topic.id
    topic.user.destroy
    assert !Topic.exists?(id)
  end

  
end
