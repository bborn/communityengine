require File.dirname(__FILE__) + '/../test_helper'

class UserModelTest < Test::Unit::TestCase

  def setup
    @jerry = create_user(:login => "jerry")
    @message = create_message
  end

  def test_unread_messages?
    assert @jerry.unread_messages?
  end

  def test_unread_message_count
    assert_equal @jerry.unread_message_count, 1
  end
end