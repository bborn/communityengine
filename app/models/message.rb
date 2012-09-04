class Message < ActiveRecord::Base  
  attr_accessor :to
  attr_accessor :reply_to

  attr_accessible :to, :subject, :body, :recipient, :sender, :recipient_id, :sender_id
  
  belongs_to :sender,     :class_name => 'User', :foreign_key => 'sender_id', :inverse_of => :sent_messages
  belongs_to :recipient,  :class_name => 'User', :foreign_key => 'recipient_id', :inverse_of => :received_messages

  belongs_to :parent, :class_name => "Message", :foreign_key => "parent_id", :inverse_of => :children
  has_many :children, :class_name => "Message", :foreign_key => "parent_id", :inverse_of => :parent
  has_many :message_threads
  
  scope :parent_messages, where("parent_id IS NULL")
  scope :already_read, where("read_at IS NOT NULL")
  scope :unread, where("read_at IS NULL")
  
  validates_presence_of :body, :subject, :sender
  validates_presence_of :recipient, :message => "is invalid"
  validate :ensure_not_sending_to_self
  
  after_create :notify_recipient
  after_create :update_message_threads
  
  
  # Ensures the passed user is either the sender or the recipient then returns the message.
  # If the reader is the recipient and the message has yet not been read, it marks the read_at timestamp.
  def self.read(id, reader)
    message = find(id, :conditions => ["sender_id = ? OR recipient_id = ?", reader, reader])
    if message.read_at.nil? && reader == message.recipient
      message.read_at = Time.now
      message.save!
    end
    message
  end
  
  # Returns true or false value based on whether the a message has been read by its recipient.
  def read?
    self.read_at.nil? ? false : true
  end
  
  # Marks a message as deleted by either the sender or the recipient, which ever the user that was passed is.
  # Once both have marked it deleted, it is destroyed.
  def mark_deleted(user)
    self.sender_deleted = true if self.sender == user
    self.recipient_deleted = true if self.recipient == user
    self.sender_deleted && self.recipient_deleted ? self.destroy : save!
  end
  
  
  def ensure_not_sending_to_self
    errors.add(:base, "You may not send a message to yourself.") if self.recipient && self.recipient.eql?(self.sender)    
  end
  
  def notify_recipient
    UserNotifier.message_notification(self).deliver
  end
  
  def update_message_threads
    recipients_thread = MessageThread.find_or_create_by_recipient_id_and_parent_message_id(self.recipient_id, (self.parent_id || self.id))
    recipients_thread.sender = sender
    recipients_thread.recipient = recipient
    recipients_thread.message = self
    recipients_thread.parent_message = (self.parent || self)
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
