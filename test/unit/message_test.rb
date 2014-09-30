require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  fixtures :all

  test "should be created" do
    message = Message.create!(:sender => users(:quentin), :recipient => users(:aaron), :body => 'hey aaron', :subject => 'Hello friend!')    
  end

  def test_should_send_notification
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      message = Message.create!(:sender => users(:quentin), :recipient => users(:aaron), :body => 'hey aaron', :subject => 'Hello friend!')
    end
  end

  def test_should_be_received
    assert_difference users(:aaron).received_messages, :count, 1 do
      Message.create!(:sender => users(:quentin), :recipient => users(:aaron), :body => 'hey aaron', :subject => 'Hello friend!')
    end
  end

  def test_should_be_invalid_without_subject
    m = Message.new(:subject => nil)
    assert !m.valid?
    assert m.errors[:subject]
  end

  def test_should_be_invalid_without_body
    m = Message.new(:body => nil)
    assert !m.valid?
    assert m.errors[:body]
  end
  
  def test_should_be_invalid_without_recipient
    m = Message.new(:recipient => nil)
    assert !m.valid?
    assert m.errors[:recipient]
  end
  
  def test_should_not_allow_message_to_self
    m = Message.new(:sender => users(:quentin), :recipient => users(:quentin))
    assert !m.valid?
    assert m.errors[:base]
  end
  
  def test_should_be_deleted_with_user
    message = Message.create!(:sender => users(:quentin), :recipient => users(:aaron), :body => 'hey aaron', :subject => 'Hello friend!')    
  
    assert_difference Message, :count, -1 do
      users(:quentin).destroy
    end
  end
  
  test "should update message threads" do
    message = messages(:message_from_kevin_to_aaron)

    assert_difference MessageThread, :count, 1 do
      message.update_message_threads    
    end
    
    mt = MessageThread.last
    assert_equal(mt.message, message)
    assert_equal(mt.recipient, users(:aaron))
    assert_equal(mt.sender, users(:kevin))
    assert_equal(mt.parent_message, message)
  end

  test "should find a message by id and mark it read if reader is the recipient" do
    message_id = messages(:message_from_kevin_to_aaron).id
    message = Message.read(message_id, users(:aaron))
    assert message.read?
  end
  
  test "should be marked as deleted and destroyed if sender & recepient have deleted" do
    message = messages(:message_from_kevin_to_aaron)
    message.mark_deleted(users(:aaron))
    assert message.recipient_deleted
    
    assert_difference Message, :count, -1 do
      message.mark_deleted(users(:kevin))
      assert message.sender_deleted
    end
    
  end
  
end
