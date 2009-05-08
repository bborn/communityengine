class Message < ActiveRecord::Base
  is_private_message
  
  attr_accessor :to
  attr_accessor :reply_to

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
  
  def self.new_reply(sender, in_reply_to = nil, params = {})
    message = new(params[:message])

    if in_reply_to
      return nil if in_reply_to.recipient != sender #can only reply to messages you received
      message.reply_to = in_reply_to
      message.to = in_reply_to.sender.login
      message.subject = "Re: #{in_reply_to.subject}"
      message.body = "\n\n*Original message*\n\n #{in_reply_to.body}"
      message.sender = sender
    end

    message
  end
  
end