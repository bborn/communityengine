class Topic < ActiveRecord::Base
  acts_as_activity :user
  
  acts_as_taggable
  belongs_to :forum, :counter_cache => true
  belongs_to :user
  has_many :monitorships
  has_many :monitors, :through => :monitorships, :conditions => ['monitorships.active = ?', true], :source => :user

  has_many :sb_posts, :order => 'sb_posts.created_at DESC', :dependent => :destroy

  belongs_to :replied_by_user, :foreign_key => "replied_by", :class_name => "User"
  
  validates_presence_of :forum, :user, :title
  before_create :set_default_replied_at_and_sticky
  after_save    :set_post_topic_id
  after_create  :create_monitorship_for_owner

  attr_accessible :title
  # to help with the create form
  attr_accessor :body
  
  scope :recently_replied, order('replied_at DESC')
  

  def notify_of_new_post(post)
    monitorships.each do |m|
      UserNotifier.new_forum_post_notice(m.user, post).deliver if (m.user != post.user) && m.user.notify_comments
    end
  end

  def to_param
    id.to_s << "-" << (title ? title.parameterize : '' )
  end

  def voices
    sb_posts.map { |p| p.user_id }.uniq.size
  end
  
  def hit!
    self.class.increment_counter :hits, id
  end

  def sticky?() sticky == 1 end

  def views() hits end

  def paged?() sb_posts_count > 25 end
  
  def last_page
    (sb_posts_count.to_f / 25.0).ceil.to_i
  end

  def editable_by?(user)
    user && (user.id == user_id || user.admin? || user.moderator_of?(forum_id))
  end
  
  protected
    def set_default_replied_at_and_sticky
      self.replied_at = Time.now.utc
      self.sticky   ||= 0
    end

    def set_post_topic_id
      SbPost.update_all ['forum_id = ?', forum_id], ['topic_id = ?', id]
    end
    
    def create_monitorship_for_owner
      monitorship = Monitorship.find_or_initialize_by_user_id_and_topic_id(user.id, self.id)
      monitorship.update_attribute :active, true      
    end
end
