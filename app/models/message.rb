class Message < ActiveRecord::Base
  is_private_message
  
  attr_accessor :to

  validates_presence_of :body, :subject
  validates_presence_of :recipient, :message => "is invalid"
  validate :ensure_not_sending_to_self

  after_create :notify_recipient
  
  def ensure_not_sending_to_self
    errors.add_to_base("You may not send a message to yourself.") if self.recipient && self.recipient.eql?(self.sender)    
  end
  
  def notify_recipient
    UserNotifier.deliver_message_notification(self)
  end
  
end