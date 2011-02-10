require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < ActiveSupport::TestCase
  fixtures :all

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
    configatron.allow_anonymous_commenting = true
    assert_difference Comment, :count, 1 do
      comment = users(:quentin).comments.create!(
        :comment => 'foo', 
        :author_email => 'bar@foo.com', 
        :author_ip => '123.123.123', 
        :recipient => users(:quentin)
      )
    end
    configatron.allow_anonymous_commenting = false
  end
  
  def test_should_notify_previous_anonymous_commenter
    configatron.allow_anonymous_commenting = true
    users(:quentin).comments.create!(:comment => 'foo', :author_email => 'bruno@foo.com', :author_ip => '123.123.123', :recipient => users(:quentin))
    users(:quentin).comments.create!(:comment => 'bar', :author_email => 'bruno@foo.com', :author_ip => '123.123.123', :recipient => users(:quentin))    

    comment = users(:quentin).comments.create!(:comment => 'bar', :author_email => 'alicia@foo.com', :author_ip => '123.123.123', :recipient => users(:quentin))        

    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      comment.notify_previous_anonymous_commenters
    end
    configatron.allow_anonymous_commenting = false
  end  
  
  def test_should_not_notify_previous_anonymous_commenter_if_self
    configatron.allow_anonymous_commenting = true
    users(:quentin).comments.create!(:comment => 'foo', :author_email => 'bruno@foo.com', :author_ip => '123.123.123', :recipient => users(:quentin))
    users(:quentin).comments.create!(:comment => 'bar', :author_email => 'bruno@foo.com', :author_ip => '123.123.123', :recipient => users(:quentin))    

    comment = users(:quentin).comments.create!(:comment => 'bar', :author_email => 'bruno@foo.com', :author_ip => '123.123.123', :recipient => users(:quentin))        

    assert_difference ActionMailer::Base.deliveries, :length, 0 do
      comment.notify_previous_anonymous_commenters
    end
    configatron.allow_anonymous_commenting = nil
  end  
  
  def test_should_not_notify_previous_anonymous_commenter_if_notify_by_email_is_false
    configatron.allow_anonymous_commenting = true
    users(:quentin).comments.create!(:comment => 'foo', :author_email => 'bruno@foo.com', :author_ip => '123.123.123', :recipient => users(:quentin), :notify_by_email => false)

    comment = users(:quentin).comments.create!(:comment => 'bar', :author_email => 'alicia@foo.com', :author_ip => '123.123.123', :recipient => users(:quentin))        

    assert_difference ActionMailer::Base.deliveries, :length, 0 do
      comment.notify_previous_anonymous_commenters
    end
    configatron.allow_anonymous_commenting = false
  end
  
  def test_should_not_be_created_anonymously
    assert_no_difference Comment, :count do
      comment = users(:quentin).comments.create(:comment => 'foo', :author_email => 'bar@foo.com', :author_ip => '123.123.123', :recipient => users(:quentin))
    end
  end
  
  def test_should_be_created_without_recipient
    assert_difference Comment, :count, 1 do
      comment = users(:aaron).comments.create!(:comment => 'foo', :user => users(:quentin))
    end  
  end

  def test_should_unsubscribe_notifications
    configatron.allow_anonymous_commenting = true
    first_comment = users(:quentin).comments.create!(:comment => 'foo', :author_email => 'alicia@foo.com', :author_ip => '123.123.123', :recipient => users(:quentin), :notify_by_email => true)        
    comment = users(:quentin).comments.create!(:comment => 'bar', :author_email => 'alicia@foo.com', :author_ip => '123.123.123', :recipient => users(:quentin), :notify_by_email => true)        
    assert_equal first_comment.notify_by_email, true
    assert_equal comment.notify_by_email, true
    configatron.allow_anonymous_commenting = false    
    
    comment.unsubscribe_notifications('alicia@foo.com')
    assert comment.reload.notify_by_email.eql?(false)
    assert first_comment.reload.notify_by_email.eql?(false)
  end
  
  def test_should_not_notify_of_comments_on_post_with_send_notifications_off
    post = posts(:funny_post)
    post.send_comment_notifications = false
    post.save!

    comment = post.comments.create!(:comment => 'foo', :user => users(:aaron), :recipient => users(:quentin))
    assert_difference ActionMailer::Base.deliveries, :length, 0 do        
      comment.send_notifications      
    end
  end


end
  