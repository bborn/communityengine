class SbPost < ActiveRecord::Base
  acts_as_activity :user, :if => Proc.new{|record| record.user } #don't record an activity if there's no user
  include Rakismet::Model
  rakismet_attrs :author => :username, :comment_type => 'comment', :content => :body, :user_ip => :author_ip

  belongs_to :forum, :counter_cache => true
  belongs_to :user,  :counter_cache => true
  belongs_to :topic, :counter_cache => true

  format_attribute :body
  before_create { |r| r.forum_id = r.topic.forum_id }
  after_create  { |r|
    Topic.where('id = ?', r.topic_id)
    .update_all(['replied_at = ?, replied_by = ?, last_post_id = ?', r.created_at, r.user_id, r.id])

  }
  after_destroy { |r|
    t = Topic.find(r.topic_id)
    Topic.where('id = ?', t.id).update_all(['replied_at = ?, replied_by = ?, last_post_id = ?', t.sb_posts.recent.last.created_at, t.sb_posts.recent.last.user_id, t.sb_posts.recent.last.id]) if t.sb_posts.recent.last
  }

  validates_presence_of :user_id, :unless => Proc.new{|record| configatron.allow_anonymous_forum_posting }
  validates_presence_of :author_email, :unless => Proc.new{|record| record.user }  #require email unless logged in
  validates_format_of :author_email, :with => /\A([^@\s]+)@((?:[-a-z0-9A-Z]+\.)+[a-zA-Z]{2,})\z/, :unless => Proc.new{|record| record.user}
  validates_presence_of :author_ip, :unless => Proc.new{|record| record.user} #log ip unless logged in

  validates_presence_of :body, :topic

  after_create :monitor_topic
  after_create :notify_monitoring_users

  scope :with_query_options, lambda {
    select('sb_posts.*, topics.title as topic_title, forums.name as forum_name')
    .joins('inner join topics on sb_posts.topic_id = topics.id inner join forums on topics.forum_id = forums.id')
    .order('sb_posts.created_at desc')
  }
  scope :recent, -> { order('sb_posts.created_at ASC') }
  validate :check_spam

  def monitor_topic
    return unless user
    monitorship = Monitorship.where(:user_id => self.user.id, :topic_id => self.topic.id).first_or_initialize
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

  def username
    user ? user.login : (author_name.blank? ? :anonymous.l : author_name)
  end

  def check_spam
    if configatron.has_key?(:akismet_key) && self.spam?
      self.errors.add(:base, :comment_spam_error.l)
    end
  end

  def dom_id
    ['sb_posts', id].join('-')
  end

end
