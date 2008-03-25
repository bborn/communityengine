require 'pp'
require File.join(File.dirname(__FILE__), 'abstract_unit')

class ActivityTrackerTest < Test::Unit::TestCase
  fixtures :test_users, :test_posts

  def test_should_create_activity
    assert_difference TestPost, :count, 1 do
      assert_difference Activity, :count, 1 do
        post = TestPost.new(:title => "New Post")
        post.test_user = test_users(:bruno)
        post.save!
      end
    end
  end
    
  def test_should_not_save_activity
    assert_no_difference Activity, :count do
      post = TestPost.new
      post.save!
    end
  end
  
  def test_should_create_unlinked_activity
    assert_difference Activity, :count, 1 do
      test_users(:bruno).track_activity(:logged_in)
    end
  end
  
  def test_should_not_create_unlinked_activity
    assert_raises(RuntimeError) do
      test_users(:bruno).track_activity(:bogus_action)
    end
  end
  
  def test_should_not_track_activity_if_user_login_is_elvis
    assert_difference TestPost, :count, 1 do
      assert_no_difference Activity, :count do
        post = TestPost.new(:title => "New Post")
        post.test_user = test_users(:elvis)
        post.save!
      end
    end    
  end
  
  
  
end
