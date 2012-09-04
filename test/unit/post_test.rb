require 'test_helper'
require 'hpricot'
    
class PostTest < ActiveSupport::TestCase
  fixtures :all

  def setup
    Favorite.destroy_all
  end

  def test_should_find_including_unpublished
    post = posts(:funny_post)
    post.save_as_draft
    assert Post.unscoped.find(post.id)
    assert Post.unscoped.all.include?(post)
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
    assert_equal 3, posts.size
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
      post = Post.new(:title => 'testing activity tracking', :raw_post => 'will this work?', :published_as => 'live')
      post.user = users(:quentin)
      post.save!
    end
  end
  
  def test_should_not_track_draft_post_activity
    assert_no_difference Activity, :count do
      post = Post.new(:title => 'testing activity tracking', :raw_post => 'will this work?', :published_as => 'draft')
      post.user = users(:quentin)
      post.save!
    end
  end  
  
  def test_should_delete_post_activity
    post = Post.new(:title => 'testing activity tracking', :raw_post => 'will this work?', :published_as => 'live')
    post.user = users(:quentin)
    post.save!

    assert_difference Activity, :count, -1 do
      post.destroy
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
    assert posts(:not_funny_post).create_poll({:question => 'Who can have a great time?'}, ['I can', 'You can', 'No one can'])
    
    assert posts(:not_funny_post).update_poll({:question => 'Who can have a terrible time?'}, ['Foo', 'Bar'])
    
    assert_equal 'Who can have a terrible time?', posts(:not_funny_post).poll.question 
    assert_equal 'Foo', posts(:not_funny_post).poll.choices.first.description
    assert_equal 'Bar', posts(:not_funny_post).poll.choices.last.description
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
  
  def test_should_set_published_at_date_when_first_published
    post = users(:quentin).posts.new(:raw_post => 'Blog post message', :title => 'Title')
    assert !post.published_at
    post.save!
    
    post.published_as = 'live'
    post.save
    assert post.published_at
  end
  
  def test_should_not_set_published_at_if_republishing  
    post = users(:quentin).posts.create!(:raw_post => 'Blog post message', :title => 'Title')
    post.save_as_live #publish
    published_at = post.published_at
    
    post.save_as_draft #unpublish
    post.save_as_live #publish again
    assert_equal post.published_at, published_at
  end
  
  def test_should_show_published_at_display
    post = posts(:funny_post)
    assert_equal post.published_at_display, I18n.l(post.published_at, :format => :published_date)
  end

  def test_should_show_published_at_display_for_draft
    post = posts(:funny_post)
    post.save_as_draft
    assert_equal post.published_at_display, 'Draft'
  end
  
  def test_should_not_notify_for_posts_without_comment_notification_on
    post = posts(:funny_post)
    post.send_comment_notifications = false
    post.save!
    
    assert_difference ActionMailer::Base.deliveries, :length, 0 do    
      comment = post.comments.create!(:comment => 'foo', :user => users(:aaron))
      comment.send_notifications      
    end
    
  end

  test "should find related" do
    p1 = posts(:funny_post)
    p2 = posts(:not_funny_post)
    
    p1.tag_list = 'tag1, tag2'
    p1.save!
    p2.tag_list = 'tag2, tag3'
    p2.save!
    
    assert Post.find_related_to(p1).include?(p2)

    p2.tag_list = 'tag3, tag4'
    p2.save!

    assert !Post.find_related_to(p1).include?(p2)    

    
  end
      
end
