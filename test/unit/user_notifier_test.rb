require File.dirname(__FILE__) + '/../test_helper'
require 'user_notifier'

class UserNotifierTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  fixtures :users, :friendships, :comments, :posts, :sb_posts, :topics, :forums

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  end

  def test_should_deliver_signup_invitation_with_name_in_email
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.deliver_signup_invitation('"Foo Bar" <foo@bar.com>', users(:quentin), 'please join')
    end
  end


  def test_should_deliver_signup_invitation  
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.deliver_signup_invitation('test@example.com', users(:quentin), 'please join')
    end
  end

  def test_should_deliver_friendship_request  
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.deliver_friendship_request(friendships(:aaron_receive_quentin_pending))
    end
  end
  
  def test_should_deliver_comment_notice
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.deliver_comment_notice(comments(:aarons_comment_on_quentins_post))
    end
  end
  
  def test_should_deliver_follow_up_comment_notice
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.deliver_follow_up_comment_notice(users(:dwr), comments(:aarons_comment_on_quentins_post))
    end    
  end
  
  def test_should_deliver_new_forum_post_notice
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.deliver_new_forum_post_notice(users(:dwr), sb_posts(:ponies))
    end        
  end
  

  def test_should_deliver_signup_notification
    users(:aaron).update_attributes(:activated_at => nil, :activation_code => "123456")
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.deliver_signup_notification(users(:aaron))
    end
  end

  def test_should_deliver_post_recommendation
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.deliver_post_recommendation('foo', 'bar@example.com', posts(:funny_post), 'check it out')
    end    
  end
  
  def test_should_deliver_activation
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.deliver_activation(users(:aaron))
    end    
  end
  
  def test_should_deliver_reset_password
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.deliver_reset_password(users(:aaron))
    end    
  end

  def test_should_deliver_forgot_username
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      UserNotifier.deliver_forgot_username(users(:aaron))
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
