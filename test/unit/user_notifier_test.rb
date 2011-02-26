require 'test_helper'
require 'hpricot'

class UserNotifierTest < ActiveSupport::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  fixtures :users, :friendships, :friendship_statuses, :comments, :posts, :sb_posts, :topics, :forums, :roles

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

  end

  def test_should_deliver_signup_invitation_with_name_in_email
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.signup_invitation('"Foo Bar" <foo@bar.com>', users(:quentin), 'please join').deliver
    end
  end


  def test_should_deliver_signup_invitation  
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.signup_invitation('test@example.com', users(:quentin), 'please join').deliver
    end
  end

  def test_should_deliver_friendship_request  
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.friendship_request(friendships(:aaron_receive_quentin_pending)).deliver
    end
  end
  
  def test_should_deliver_friendship_accepted_notification
    f = friendships(:aaron_receive_quentin_pending)    
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      f.update_attributes(:friendship_status => FriendshipStatus[:accepted]) && f.reverse.update_attributes(:friendship_status => FriendshipStatus[:accepted])          
    end    
  end
  
  def test_should_deliver_comment_notice
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.comment_notice(comments(:aarons_comment_on_quentins_post)).deliver
    end
  end
  
  def test_should_deliver_follow_up_comment_notice
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.follow_up_comment_notice(users(:dwr), comments(:aarons_comment_on_quentins_post)).deliver
    end    
  end
  
  def test_should_deliver_follow_up_comment_notice_anonymous
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.follow_up_comment_notice_anonymous('test@example.com', comments(:aarons_comment_on_quentins_post)).deliver
    end    
  end  
  
  def test_should_deliver_new_forum_post_notice
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.new_forum_post_notice(users(:dwr), sb_posts(:ponies)).deliver
    end        
  end
  

  def test_should_deliver_signup_notification
    users(:aaron).update_attributes(:activated_at => nil, :activation_code => "123456")
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.signup_notification(users(:aaron)).deliver
    end
  end

  def test_should_deliver_post_recommendation
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.post_recommendation('foo', 'bar@example.com', posts(:funny_post), 'check it out').deliver
    end    
  end
  
  def test_should_deliver_activation
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.activation(users(:aaron)).deliver
    end    
  end
  
  def test_should_deliver_password_reset_instructions
    activate_authlogic
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.password_reset_instructions(users(:aaron)).deliver
    end    
  end

  def test_should_deliver_forgot_username
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.forgot_username(users(:aaron)).deliver
    end    
  end
  
  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/user_notifier/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
