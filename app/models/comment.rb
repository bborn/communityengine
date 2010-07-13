class Comment < ActiveRecord::Base
  include Rakismet::Model
  rakismet_attrs :author => :author_name, :comment_type => 'comment', :content => :comment, :user_ip => :author_ip
  
  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  belongs_to :recipient, :class_name => "User", :foreign_key => "recipient_id"
  
  validates_presence_of :comment
  validates_presence_of :commentable_id, :commentable_type
  
  validates_length_of :comment, :maximum => 2000
  
  before_save :whitelist_attributes  

  validates_presence_of :user, :unless => Proc.new{|record| AppConfig.allow_anonymous_commenting }
  validates_presence_of :author_email, :unless => Proc.new{|record| record.user }  #require email unless logged in
  validates_presence_of :author_ip, :unless => Proc.new{|record| record.user} #log ip unless logged in
  validates_format_of :author_url, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix, :unless => Proc.new{|record| record.user }
  validate :check_spam
  
  acts_as_activity :user, :if => Proc.new{|record| record.user } #don't record an activity if there's no user

  # named_scopes
  named_scope :recent, :order => 'created_at DESC'

  def self.find_photo_comments_for(user)
    Comment.find(:all, :conditions => ["recipient_id = ? AND commentable_type = ?", user.id, 'Photo'], :order => 'created_at DESC', :limit => 10)
  end
  
  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  def self.find_comments_by_user(user, *args)
    options = args.extract_options!
    find(:all,
      :conditions => ["user_id = ?", user.id],
      :order => "created_at DESC",
      :limit => options[:limit]  
    )
  end
    
  def previous_commenters_to_notify
    # only send a notification on recent comments
    # limit the number of emails we'll send (or posting will be slooowww)
    User.find(:all, 
      :conditions => ["users.id NOT IN (?) AND users.notify_comments = ? 
                      AND commentable_id = ? AND commentable_type = ? 
                      AND comments.notify_by_email = ? 
                      AND comments.created_at > ?", [user_id, recipient_id.to_i], true, commentable_id, commentable_type, true, 2.weeks.ago], 
#      :include => :comments_as_author, :group => "users.id", :limit => 20)    
      :include => :comments_as_author, :limit => 20)
  end    
    
  def commentable_name
    type = self.commentable_type.underscore
    case type
      when 'user'
        commentable.login
      when 'post'
        commentable.title
      when 'clipping'
        commentable.description || "Clipping from #{commentable.user.login}"
      when 'photo'
        commentable.description || "Photo from #{commentable.user.login}"
      else 
        commentable.class.to_s.humanize
    end
  end

  def title_for_rss
    "Comment from #{username}"
  end
  
  def username
    user ? user.login : (author_name.blank? ? 'Anonymous' : author_name)
  end
  
  def self.find_recent(options = {:limit => 5})
    find(:all, :conditions => "created_at > '#{14.days.ago.to_s :db}'", :order => "created_at DESC", :limit => options[:limit])
  end
  
  def can_be_deleted_by(person)
    person && (person.admin? || person.id.eql?(user_id) || person.id.eql?(recipient_id) )
  end
  
  def should_notify_recipient?
    return unless recipient
    return false if recipient.eql?(user)
    return false unless recipient.notify_comments?
    true    
  end
  
  def notify_previous_commenters
    previous_commenters_to_notify.each do |commenter|
      UserNotifier.deliver_follow_up_comment_notice(commenter, self)
    end    
  end
  
  def notify_previous_anonymous_commenters
    anonymous_commenters_emails = commentable.comments.map{|c|  c.author_email if (c.notify_by_email? && !c.user && !c.author_email.eql?(self.author_email) && c.author_email) }.uniq.compact
    anonymous_commenters_emails.each do |email|
      UserNotifier.deliver_follow_up_comment_notice_anonymous(email, self)
    end    
  end  
  
  def send_notifications
    UserNotifier.deliver_comment_notice(self) if should_notify_recipient?
    self.notify_previous_commenters
    self.notify_previous_anonymous_commenters if AppConfig.allow_anonymous_commenting
  end
  
  def token_for(email)
    Digest::SHA1.hexdigest("#{id}--#{email}--#{created_at}")                
  end
  
  def unsubscribe_notifications(email)
    commentable.comments.find_all_by_author_email(email).each do |previous_comment|
      previous_comment.update_attribute :notify_by_email, false
    end
  end
  
  def check_spam
    if AppConfig.akismet_key && self.spam?
      self.errors.add_to_base(:comment_spam_error.l) 
    end
  end  
  
  protected
    def whitelist_attributes
      self.comment = white_list(self.comment)
    end  

end
