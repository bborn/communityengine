class Comment < ActiveRecord::Base
  include ActionController::UrlWriter
  default_url_options[:host] = APP_URL.sub('http://', '')

  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  belongs_to :recipient, :class_name => "User", :foreign_key => "recipient_id"
  
  validates_presence_of :user
  validates_presence_of :comment
  validates_presence_of :recipient
  
  validates_length_of :comment, :maximum => 2000
  
  before_save :whitelist_attributes  

  acts_as_activity :user  

  def self.find_photo_comments_for(user)
    Comment.find(:all, :conditions => ["recipient_id = ? AND commentable_type = ?", user.id, 'Photo'], :order => 'created_at DESC')
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
                      AND comments.created_at > ?", [user_id, recipient_id], true, commentable_id, commentable_type, 2.weeks.ago], 
      :include => :comments_as_author, :group => "users.id", :limit => 20)    
  end    
    
  def commentable_name
    type = Inflector.underscore(self.commentable_type)
    case type
      when 'user'
        commentable.login
      when 'post'
        commentable.title
      when 'clipping'
        commentable.description || "Clipping from #{commentable.user.login}"
      when 'photo'
        commentable.description || "Photo from #{commentable.user.login}"
    end
  end
  
  def generate_commentable_url(comment_anchor = true)
    type = Inflector.underscore(self.commentable_type)
    url = ''
    if (type.eql?('user'))
      url = user_url(self.recipient)
    else
      url = instance_eval("user_#{type}_url(:user_id => self.recipient, :id => self.commentable)")
    end
    url += "#comment_#{self.id}" if comment_anchor
    url
  end
  
  def title_for_rss
    "Comment from #{user.login}"
  end
  
  def self.find_recent(options = {:limit => 5})
    find(:all, :conditions => "created_at > '#{14.days.ago.to_s :db}'", :order => "created_at DESC", :limit => options[:limit])
  end
  
  def can_be_deleted_by(person)
    person && (person.admin? || person.eql?(user) || person.eql?(recipient) )
  end
  
  
  protected
  def whitelist_attributes
    self.comment = white_list(self.comment)
  end
  

end