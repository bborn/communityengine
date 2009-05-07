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
  
  def self.new_reply(user, params = {})
    message = new(params[:message])

    if params[:reply_to]
      reply_to = user.received_messages.find(params[:reply_to])
      unless reply_to.nil?
        message.reply_to = reply_to
        message.to = reply_to.sender.login
        message.subject = "Re: #{reply_to.subject}"
        message.body = "\n\n*Original message*\n\n #{reply_to.body}"
      end
    end
    
    message
  end
  
end