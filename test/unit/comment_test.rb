require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < Test::Unit::TestCase
  fixtures :comments, :users, :posts, :roles

  def test_should_find_comments_by_user
    comments = Comment.find_comments_by_user(users(:quentin))
    assert !comments.empty?
  end
  
  def test_comment_can_be_deleted_by
    comment = comments(:aarons_comment_on_quentins_post)
    assert comment.can_be_deleted_by(users(:aaron))
    assert comment.can_be_deleted_by(users(:quentin))    
    assert !comment.can_be_deleted_by(users(:florian))
  end
    
  def test_should_be_created_anonymously
    AppConfig.allow_anonymous_commenting = true
    assert_difference Comment, :count, 1 do
      comment = Comment.create!(:comment => 'foo', :author_email => 'bar@foo.com', :author_ip => '123.123.123', :recipient => users(:quentin), :commentable => users(:quentin))
    end
    AppConfig.allow_anonymous_commenting = false
  end
  
  def test_should_notify_previous_anonymous_commenter
    AppConfig.allow_anonymous_commenting = true
    Comment.create!(:comment => 'foo', :author_email => 'bruno@foo.com', :author_ip => '123.123.123', :recipient => users(:quentin), :commentable => users(:quentin))
    Comment.create!(:comment => 'bar', :author_email => 'bruno@foo.com', :author_ip => '123.123.123', :recipient => users(:quentin), :commentable => users(:quentin))    

    comment = Comment.create!(:comment => 'bar', :author_email => 'alicia@foo.com', :author_ip => '123.123.123', :recipient => users(:quentin), :commentable => users(:quentin))        

    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      comment.notify_previous_anonymous_commenters
    end
    AppConfig.allow_anonymous_commenting = false
  end  
  
  
  def test_should_not_be_created_anonymously
    assert_no_difference Comment, :count do
      comment = Comment.create(:comment => 'foo', :author_email => 'bar@foo.com', :author_ip => '123.123.123', :recipient => users(:quentin))
    end
  end
  
  def test_should_be_created_without_recipient
    assert_difference Comment, :count, 1 do
      comment = Comment.create!(:comment => 'foo', :user => users(:quentin), :commentable => users(:aaron))
    end  
  end


end
  