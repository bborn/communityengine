require File.dirname(__FILE__) + '/../test_helper'
require 'hpricot'
    
class PostTest < Test::Unit::TestCase
  fixtures :posts, :users, :comments

  def setup
    Favorite.destroy_all
  end

  def test_should_find_including_unpublished
    post = posts(:funny_post)
    post.save_as_draft
    assert Post.find_without_published_as(:all).include?(post)
  end
  
  def test_default_find_should_not_find_drafts
    post = posts(:funny_post)
    post.save_as_draft
    assert !Post.find(:all).include?(post)    
  end
  
  def test_should_find_recent
    posts = Post.find_recent(:limit => 3)
    assert_equal posts.size, 3
    posts = Post.find_recent
    assert_equal posts.size, 4
  end

  def test_should_find_popular
    posts = Post.find_popular(:limit => 3, :since => 10.days)
    assert_equal posts.size, 3
    posts = Post.find_popular(:limit => 3, :since => 1.days)
    assert_equal posts.size, 0
  end
  
  def test_should_display_name
    post = posts(:funny_post)
    assert_equal post.display_title, "HOW TO: Building communities is all about love."
  end
  
  def test_should_find_previous_post
    previous = posts(:not_funny_post).previous_post
    assert_equal previous, posts(:funny_post)
  end
  
  def test_should_find_next_post
    next_post = posts(:funny_post).next_post
    assert_equal next_post, posts(:not_funny_post)
  end
  
  def test_should_track_post_activity
    assert_difference Activity, :count, 1 do
      post = Post.new(:title => 'testing activity tracking', :raw_post => 'will this work?')
      post.user = users(:quentin)
      post.save!
    end
  end
  
  # def test_link_for_rss
  #   assert_equal posts(:funny_post).link_for_rss, "http://localhost:3000/quentin/posts/1-This-is-really-good-stuff"
  # end
  
  def test_create_poll
    assert_difference Poll, :count, 1 do
      assert_difference Choice, :count, 3 do
        assert posts(:funny_post).create_poll({:question => 'Who can have a great time?'}, ['I can', 'You can', 'No one can'])
      end
    end
  end
  
  def test_should_not_add_empty_poll
    assert_no_difference Poll, :count do
      assert_no_difference Choice, :count do
        posts(:funny_post).create_poll({:question => 'Who can have a great time?'}, ['only one choice'])
      end
    end    
  end
  
  def test_should_not_create_poll_with_no_choices
    assert_no_difference Poll, :count do
      assert_no_difference Choice, :count do
        posts(:funny_post).create_poll({:question => 'Who can have a great time?'}, [])
      end
    end    
  end
  
  def test_update_poll
    assert posts(:funny_post).create_poll({:question => 'Who can have a great time?'}, ['I can', 'You can', 'No one can'])
    
    assert posts(:funny_post).update_poll({:question => 'Who can have a terrible time?'}, ['Foo', 'Bar'])
    
    assert_equal posts(:funny_post).poll.question, 'Who can have a terrible time?'
    assert_equal posts(:funny_post).poll.choices.first.description, 'Foo'
    assert_equal posts(:funny_post).poll.choices.last.description, 'Bar'
  end
  
  def test_update_poll_with_no_choices_should_delete_poll
    assert posts(:funny_post).create_poll({:question => 'Who can have a great time?'}, ['I can', 'You can', 'No one can'])

    assert_difference Poll, :count, -1 do
      assert posts(:funny_post).update_poll({:question => 'Who can have a terrible time?'}, [])
    end
  end  
  
  def test_should_find_most_commented
    assert_equal posts(:funny_post).id, Post.find_most_commented.first.id
    assert_equal posts(:apt_post).id, Post.find_most_commented.last.id        
  end

  def test_find_recent
    assert Post.find_recent(:limit => 30)
  end
  
  def test_image_for_excerpt_for_post_with_no_image_returns_avatar_url
    assert_equal posts(:funny_post).user.avatar_photo_url(:medium), posts(:funny_post).image_for_excerpt
  end
  
  def test_has_been_favorited_by_user
    post  = posts(:funny_post)
    assert !post.has_been_favorited_by(users(:quentin))

    favorite = Favorite.new(:ip_address => '1.1.1.1', :favoritable => post )
    favorite.user = users(:quentin)
    favorite.save
    
    assert post.has_been_favorited_by(users(:quentin))    
  end
    
end
