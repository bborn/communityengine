class SbPost < ActiveRecord::Base
  acts_as_activity :user
  
  belongs_to :forum, :counter_cache => true
  belongs_to :user,  :counter_cache => true
  belongs_to :topic, :counter_cache => true

  format_attribute :body
  before_create { |r| r.forum_id = r.topic.forum_id }
  after_create  { |r| 
    Topic.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?', r.created_at, r.user_id, r.id], ['id = ?', r.topic_id]) 
  }
  after_destroy { |r| 
    t = Topic.find(r.topic_id)
    Topic.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?', t.sb_posts.recent.last.created_at, t.sb_posts.recent.last.user_id, t.sb_posts.recent.last.id], ['id = ?', t.id]) if t.sb_posts.recent.last 
  }

  validates_presence_of :user_id, :unless => Proc.new{|record| configatron.allow_anonymous_forum_posting }
  validates_presence_of :author_email, :unless => Proc.new{|record| record.user }  #require email unless logged in
  validates_format_of :author_email, :with => /^([^@\s]+)@((?:[-a-z0-9A-Z]+\.)+[a-zA-Z]{2,})$/, :unless => Proc.new{|record| record.user}
  validates_presence_of :author_ip, :unless => Proc.new{|record| record.user} #log ip unless logged in

  validates_presence_of :body, :topic
  
  attr_accessible :body, :author_email, :author_ip, :author_name, :author_url
  after_create :monitor_topic
  after_create :notify_monitoring_users  
  
  scope :with_query_options, :select => 'sb_posts.*, topics.title as topic_title, forums.name as forum_name', :joins => 'inner join topics on sb_posts.topic_id = topics.id inner join forums on topics.forum_id = forums.id', :order => 'sb_posts.created_at desc'
  scope :recent, :order => 'sb_posts.created_at ASC'
  
  def monitor_topic
    return unless user    
    monitorship = Monitorship.find_or_initialize_by_user_id_and_topic_id(self.user.id, self.topic.id)
    if monitorship.new_record?
      monitorship.update_attribute :active, true
    end
  end
  
  def notify_monitoring_users
    topic.notify_of_new_post(self)
  end
  
  def editable_by?(user)
    user && (user.id == user_id || user.admin? || user.moderator_of?(topic.forum_id))
  end
  
  def to_xml(options = {})
    options[:except] ||= []
    options[:except] << :topic_title << :forum_name
    super
  end
  
  def username
    user ? user.login : (author_name.blank? ? :anonymous.l : author_name)
  end
  
  def check_spam
    if configatron.akismet_key && self.spam?
      self.errors.add_to_base(:comment_spam_error.l) 
    end
  end  
  
end
