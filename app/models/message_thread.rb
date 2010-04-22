class MessageThread < ActiveRecord::Base
  belongs_to :message
  belongs_to :parent_message, :class_name => 'Message'
  belongs_to :sender, :class_name => 'User', :foreign_key => "sender_id"
  belongs_to :recipient, :class_name => 'User', :foreign_key => "recipient_id"
  
  def subject
    parent_message.subject
  end
  
  def creator_name
    parent_message.sender.eql?(recipient) ? 'Me' : parent_message.sender.login
  end
  
  def self.for(message, user)
    find(:first, :conditions => {:parent_message_id => (message.parent_id || message.id), :recipient_id => user.id})
  end
  
  
end