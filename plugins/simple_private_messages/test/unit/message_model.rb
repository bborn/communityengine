require File.dirname(__FILE__) + '/../test_helper'

class MessageModelTest < Test::Unit::TestCase

  def setup
    @jerry = create_user(:login => "jerry")
    @george = create_user(:login => "george")
    @message = create_message
  end

  def test_create_message
    @message = create_message
    
    assert_equal @message.sender, @george
    assert_equal @message.recipient, @jerry
    assert_equal @message.subject, "Frolf, Jerry!"
    assert_equal @message.body, "Frolf, Jerry! Frisbee golf!"
    assert @message.read_at.nil?
  end

  def test_read_returns_message
    assert_equal @message, Message.read(@message, @george)
  end

  def test_read_records_timestamp
    assert !@message.nil?
  end
  
  def test_read?
    Message.read(@message, @jerry)
    @message.reload
    assert @message.read?
  end
  
  def test_mark_deleted_sender
    @message.mark_deleted(@george)
    @message.reload
    assert @message.sender_deleted
  end

  def test_mark_deleted_recipient
    @message.mark_deleted(@jerry)
    @message.reload
    assert @message.recipient_deleted
  end

  def test_mark_deleted_both
    id = @message.id
    @message.mark_deleted(@jerry)
    @message.mark_deleted(@george)
    assert !Message.exists?(id)
  end

end