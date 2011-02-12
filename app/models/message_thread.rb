class MessageThread < ActiveRecord::Base
  belongs_to :message
  belongs_to :parent_message, :class_name => 'Message'
  belongs_to :sender, :class_name => 'User', :foreign_key => "sender_id"
  belongs_to :recipient, :class_name => 'User', :foreign_key => "recipient_id"
  
  before_destroy :mark_messages_deleted
  
  def subject
    parent_message.subject
  end
  
  def creator_name
    parent_message.sender.eql?(recipient) ? 'Me' : parent_message.sender.login
  end
  
  def self.for(message, user)
    find(:first, :conditions => {:parent_message_id => (message.parent_id || message.id), :recipient_id => user.id})
  end
  
  def mark_messages_deleted
    parent_message.mark_deleted(recipient)
    parent_message.children.each do |child|
      child.mark_deleted(recipient)
    end
  end
  
  def read?
    puts message.inspect
    puts self.inspect
    message.recipient.eql?(recipient) ? message.read? : 'read'
  end
  
  
end