require 'test_helper'

class MessageThreadTest < ActiveSupport::TestCase
  fixtures :all
  
  test "subject should equal parent message subject" do
    message_thread = MessageThread.new(:parent_message => messages(:message_from_kevin_to_aaron))
    assert_equal(message_thread.subject, messages(:message_from_kevin_to_aaron).subject)
  end
  
  test "creator_name should be parent message's sender login " do
    message_thread = MessageThread.new(:parent_message => messages(:message_from_kevin_to_aaron), :recipient => users(:aaron), :sender => users(:kevin))    
    assert_equal(message_thread.creator_name, users(:kevin).login )
  end
  
  test "creator_name should be 'Me' when sender parent message sender is recipient " do
    message_thread = MessageThread.new(:parent_message => messages(:message_from_kevin_to_aaron), :recipient => users(:kevin), :sender => users(:aaron))    
    assert_equal(message_thread.creator_name, 'Me' )
  end
  
  test "should find MessageThread for a particular message and user" do
    messages(:message_from_kevin_to_aaron).update_message_threads
    aarons_thread = messages(:message_from_kevin_to_aaron).message_threads.first
    
    message_thread = MessageThread.for(messages(:message_from_kevin_to_aaron), users(:aaron))
    assert_equal message_thread, aarons_thread
  end
  
  test "should mark recipient's messages as deleted when destroyed" do
    messages(:message_from_kevin_to_aaron).update_message_threads
    aarons_thread = messages(:message_from_kevin_to_aaron).message_threads.first
    
    aarons_thread.destroy
    assert aarons_thread.parent_message.recipient_deleted
    assert !aarons_thread.parent_message.sender_deleted    
  end
  
  
  test "should mark sender's messages as deleted when destroyed" do
    message = messages(:message_from_kevin_to_aaron)
    message.update_message_threads
    message_thread = MessageThread.for(message, users(:aaron))
    
    # create a reply from aaron to kevin's message
    reply = Message.new_reply(users(:aaron), message_thread, {:message => { :body => 'Hey kevin, just replying to your message'}})    
    reply.recipient = users(:kevin)
    reply.save!
  
    kevins_thread = MessageThread.for(reply, users(:kevin))
    kevins_thread.destroy
    
    #Parent message was sent by kevin, should be deleted by kevin and not by aaron
    assert kevins_thread.parent_message.sender_deleted, 'The parent message should be marked as deleted for by sender'
    assert !kevins_thread.parent_message.recipient_deleted, 'The parent message should not be marked as deleted by the recipient'    
  
    #Child message was sent by aaron, should be deleted by kevin and not by aaron. Whew.
    assert kevins_thread.parent_message.children.first.recipient_deleted, 'The child message should be deleted by the recipient'
    assert !kevins_thread.parent_message.children.first.sender_deleted, 'The child message should not be marked as deleted by the sender'
  end

  test "read? should always be 'read' for the sender" do
    message = messages(:message_from_kevin_to_aaron)
    message.update_message_threads

    aarons_thread = MessageThread.for(message, users(:aaron))
    assert_equal aarons_thread.read?, false 
  
    # create a reply from aaron to kevin's message
    reply = Message.new_reply(users(:aaron), aarons_thread, {:message => { :body => 'Hey kevin, just replying to your message'}})    
    reply.recipient = users(:kevin)
    reply.save!
    
    aarons_thread = MessageThread.for(reply, users(:aaron))    
    
    assert_equal aarons_thread.read?, 'read'
    
  end


end
