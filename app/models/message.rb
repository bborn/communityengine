class Message < ActiveRecord::Base
  is_private_message
  
  attr_accessor :to
  attr_accessor :reply_to
  
  belongs_to :parent, :class_name => "Message", :foreign_key => "parent_id"
  has_many :children, :class_name => "Message", :foreign_key => "parent_id"
  has_many :message_threads

  # named_scope :conversation_roots, :conditions => "parent_id IS NULL"

  validates_presence_of :body, :subject
  validates_presence_of :recipient, :message => "is invalid"
  validate :ensure_not_sending_to_self

  after_create :notify_recipient
  after_create :update_message_threads
  
  def ensure_not_sending_to_self
    errors.add_to_base("You may not send a message to yourself.") if self.recipient && self.recipient.eql?(self.sender)    
  end
  
  def notify_recipient
    UserNotifier.deliver_message_notification(self)
  end
  
  def update_message_threads
    recipients_thread = MessageThread.find_or_create_by_recipient_id_and_parent_message_id(self.recipient_id, (self.parent_id || self.id))
    recipients_thread.attributes = {:sender => sender, :recipient => recipient, :message => self, :parent_message => (self.parent || self)}
    recipients_thread.save
    
    if parent
      senders_thread = MessageThread.find_or_create_by_recipient_id_and_parent_message_id(self.sender_id, self.parent_id)
      senders_thread.message = self
      senders_thread.save
    end
  end
  
  def self.new_reply(sender, message_thread = nil, params = {})
    message = new(params[:message])
    message.to ||= params[:to] if params[:to]

    if message_thread
      message.parent = message_thread.parent_message
      message.reply_to = message_thread.message
      message.to = message_thread.sender.login
      message.subject = message_thread.parent_message.subject
      message.sender = sender
    end

    message
  end
    
end
