class SbPost < ActiveRecord::Base
  acts_as_activity :user
  
  belongs_to :forum, :counter_cache => true
  belongs_to :user,  :counter_cache => true
  belongs_to :topic, :counter_cache => true

  format_attribute :body
  before_create { |r| r.forum_id = r.topic.forum_id }
  after_create  { |r| Topic.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?', r.created_at, r.user_id, r.id], ['id = ?', r.topic_id]) }
  after_destroy { |r| t = Topic.find(r.topic_id) ; Topic.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?', t.sb_posts.last.created_at, t.sb_posts.last.user_id, t.sb_posts.last.id], ['id = ?', t.id]) if t.sb_posts.last }

  validates_presence_of :user_id, :body, :topic
  attr_accessible :body
  after_create :monitor_topic   
  after_create :notify_monitoring_users
  
  def monitor_topic
    monitorship = Monitorship.find_or_initialize_by_user_id_and_topic_id(user.id, topic.id)
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
end
