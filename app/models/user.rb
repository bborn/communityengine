require 'digest/sha1'

class User < ActiveRecord::Base  
  include ActionController::UrlWriter
  default_url_options[:host] = APP_URL.sub('http://', '')
  MALE    = 'M'
  FEMALE  = 'F'

  attr_protected :admin, :featured, :role_id
  
  before_save :encrypt_password, :whitelist_attributes
  before_create :make_activation_code
  after_create :update_last_login
  after_create {|user| UserNotifier.deliver_signup_notification(user) }
  after_save   {|user| UserNotifier.deliver_activation(user) if user.recently_activated? }  

  # Virtual attribute for the unencrypted password
  attr_accessor :password
  acts_as_taggable  
  acts_as_commentable
  tracks_unlinked_activities [:logged_in, :invited_friends, :updated_profile]  

  #validation
  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 6..20, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_presence_of     :metro_area,                 :if => Proc.new { |user| user.state }
  validates_length_of       :login,    :within => 5..20
  validates_length_of       :email,    :within => 3..100
  validates_format_of       :email, :with => /^([^@\s]+)@((?:[-a-z0-9A-Z]+\.)+[a-zA-Z]{2,})$/
  validates_format_of       :login, :with => /^[\sA-Za-z0-9_-]+$/
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_uniqueness_of   :login_slug
  validates_date :birthday, :before => 13.years.ago.to_date  

  has_many :posts, :order => "published_at desc", :dependent => :destroy
  has_many :photos, :order => "created_at desc", :dependent => :destroy
  has_many :invitations, :dependent => :destroy
  has_many :offerings, :dependent => :destroy

  has_enumerated :role  

  #friends
  has_many :friendships, :class_name => "Friendship", :foreign_key => "user_id", :dependent => :destroy
  has_many :accepted_friendships, :class_name => "Friendship", :conditions => ['friendship_status_id = ?', 2]
  has_many :pending_friendships, :class_name => "Friendship", :conditions => ['initiator = ? AND friendship_status_id = ?', false, 1]
  has_many :friendships_initiated_by_me, :class_name => "Friendship", :foreign_key => "user_id", :conditions => ['initiator = ?', true], :dependent => :destroy
  has_many :friendships_not_initiated_by_me, :class_name => "Friendship", :foreign_key => "user_id", :conditions => ['initiator = ?', false], :dependent => :destroy
  has_many :occurances_as_friend, :class_name => "Friendship", :foreign_key => "friend_id", :dependent => :destroy

  #forums
  has_many :moderatorships, :dependent => :destroy
  has_many :forums, :through => :moderatorships, :order => 'forums.name'
  has_many :sb_posts, :dependent => :destroy
  has_many :topics, :dependent => :destroy
  has_many :monitorships, :dependent => :destroy
  has_many :monitored_topics, :through => :monitorships, :conditions => ['monitorships.active = ?', true], :order => 'topics.replied_at desc', :source => :topic

  belongs_to :avatar, :class_name => "Photo", :foreign_key => "avatar_id"
  belongs_to :metro_area
  belongs_to :state
  belongs_to :country
  has_many :comments_as_author, :class_name => "Comment", :foreign_key => "user_id", :order => "created_at desc", :dependent => :destroy
  has_many :comments_as_recipient, :class_name => "Comment", :foreign_key => "recipient_id", :order => "created_at desc", :dependent => :destroy
  has_many :clippings, :order => "created_at desc", :dependent => :destroy
  has_many :favorites, :order => "created_at desc", :dependent => :destroy
  
  #callbacks
  before_save :generate_login_slug
  after_save    :recount_metro_area_users
  after_destroy :recount_metro_area_users
  
  def moderator_of?(forum)
    moderatorships.count(:all, :conditions => ['forum_id = ?', (forum.is_a?(Forum) ? forum.id : forum)]) == 1
  end
  
  def monitoring_topic?(topic)
    monitored_topics.find_by_id(topic.id)
  end

  def to_xml(options = {})
    options[:except] ||= []
    super
  end

  def password_required?
    true
  end  
  
  def recount_metro_area_users
    return unless self.metro_area
    ma = self.metro_area
    ma.users_count = User.count(:conditions => ["metro_area_id = ?", ma.id])
    ma.save
  end  
  
  def to_param
    login_slug
  end

  # override activerecord's find to allow us to find by name or id transparently
  def self.find(*args)
    if args.is_a?(Array) and args.first.is_a?(String) and (args.first.index(/[a-zA-Z\-_]+/) or args.first.to_i.eql?(0) )
      find_by_login_slug(args)
    else
      super
    end
  end

  def self.find_active(options = {:limit => 10})
    commented_on = Comment.find(:all, :limit => 3, :include => :recipient, :conditions => "users.avatar_id is not null and users.featured_writer = 0", :order => "comments.created_at desc").collect{ |c| c.recipient }.uniq
    posters = Post.find(:all, :limit => 3, :include => :user, :conditions => "users.avatar_id is not null and users.featured_writer = 0" ,:order => "posts.published_at DESC").collect{ |p| p.user }.uniq
    full = commented_on | posters
    full.sort{ |a,b| b.updated_at <=> a.updated_at }[0..options[:limit]]
  end
    
  def self.find_by_activity(options = {})
    options.reverse_merge! :limit => 30, :require_avatar => true, :since => 7.days.ago   
    
    activities = Activity.find(
      :all, 
      :select => '*, count(*) as count', 
      :group => "activities.user_id", 
      :conditions => ["activities.created_at > ? #{options[:require_avatar] ? ' AND users.avatar_id IS NOT NULL' : ''}", options[:since]], 
      :order => 'count DESC', 
      :joins => "LEFT JOIN users ON users.id = activities.user_id",
      :limit => options[:limit]
      )
    activities.map{|a| find(a.user_id) }
  end  
    
  def self.find_featured
    self.find(:all, :conditions => "featured_writer = 1")
  end
  
  def this_months_posts
    self.posts.find(:all, :conditions => ["published_at > ?", DateTime.now.to_time.at_beginning_of_month])
  end
  
  def last_months_posts
    self.posts.find(:all, :conditions => ["published_at > ? and published_at < ?", DateTime.now.to_time.at_beginning_of_month.months_ago(1), DateTime.now.to_time.at_beginning_of_month])
  end
  
  def avatar_photo_url(size = nil)
    if avatar
      avatar.public_filename(size)
    else
      case size
        when :thumb
          AppConfig.photo['missing_thumb']
        else
          AppConfig.photo['missing_medium']
      end
    end
  end


  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    # hide records with a nil activated_at
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login]
    u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL', login] if u.nil?
    u && u.authenticated?(password) && u.update_last_login ? u : nil
  end

  # Activates the user in the database.
  def activate
    @activated = true
    update_attributes(:activated_at => Time.now.utc, :activation_code => nil)
  end
  
  def active?
    activation_code.nil?
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end
  
  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  

  def generate_invite_url
    "#{APP_URL}/signup/#{self.to_param}/#{invite_code}"
  end
  
  def valid_invite_code?(code)
    code == invite_code
  end
  
  def invite_code
    Digest::SHA1.hexdigest("#{self.id}--#{self.email}--#{self.salt}")
  end
  
  def location
    loc = ""
    loc = self.metro_area.name if self.metro_area
  end
  
  def full_location
    loc = ""
    (loc += self.metro_area.name) if self.metro_area
    (loc += ", " + self.country.name) if self.country
    loc
  end
  
  def reset_password
     p = newpass(8)
     self.password = p
     self.password_confirmation = p
     return self.valid?
  end

  def newpass( len )
     chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
     newpass = ""
     1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
     return newpass
  end
  
  def owner
    self
  end

  def staff?
    featured_writer?
  end
  
  def can_request_friendship_with(user)
    !self.eql?(user) && !self.friendship_exists_with?(user)
  end

  def friendship_exists_with?(friend)
    Friendship.find(:first, :conditions => ["user_id = ? AND friend_id = ?", self.id, friend.id])
  end
  
  # before filter
  def generate_login_slug
    self.login_slug = self.login.gsub(/[^a-z1-9]+/i, '-')
  end

  def update_last_login
     self.update_attribute(:last_login_at, Time.now)
  end
  
  def add_offerings(skills)
    skills.each do |skill_id|
      offering = Offering.new(:skill_id => skill_id)
      offering.user = self
      if self.under_offering_limit? && !self.has_skill?(offering.skill)
        if offering.save
          self.offerings << offering
        end
      end
    end
  end  
  
  def under_offering_limit?
    self.offerings.size < 3
  end
  
  def has_skill?(skill)
    self.offerings.collect{|o| o.skill }.include?(skill)
  end

  def has_reached_daily_friend_request_limit?
    friendships_initiated_by_me.count(:conditions => ['created_at > ?', Time.now.beginning_of_day]) >= Friendship.daily_request_limit
  end

  def self.paginated_users_conditions_with_search(params)
    search = {}.merge(params)
    search['metro_area_id'] = params[:metro_area_id] || nil
    search['state_id'] = params[:state_id] || nil
    search['country_id'] = params[:country_id] || nil
    search['skill_id'] = params[:skill_id] || nil    
    if search['metro_area_id']
      metro_area = MetroArea.find(search['metro_area_id'])
      country = metro_area.country
      state = metro_area.state 
      search['country_id'] = country.id if country
      search['state_id'] = state.id if state
      metro_areas = metro_area.state ? metro_area.state.metro_areas : metro_area.country.metro_areas
    end
    metro_areas ||= search['state_id'].blank? ? [] : State.find(search['state_id']).metro_areas
    states = search['state_id'].blank? ? [] : State.find(:all)    
    
    cond = Caboose::EZ::Condition.new
    cond.append ['activated_at is not null ']
    if search['country_id']  
      cond.append ['country_id = ?', search['country_id']]
    end
    if search['state_id']
      cond.append ['state_id = ?', search['state_id']]
    end
    if search['metro_area_id']
      cond.append ['metro_area_id = ?', search['metro_area_id']]
    end
    if search['login']    
      cond.login =~ "%#{search['login']}%"
    end
    if search['vendor']
      cond.vendor == true
    end    
    if search['description']
      cond.description =~ "%#{search['description']}%"
    end
    return cond, search, metro_areas, states
  end

  def network_activity(page = {}, since = 1.week.ago)
    page.reverse_merge :size => 10, :current => 1
    
    ids = self.friends_ids
    Activity.find(:all, 
      :conditions => ['user_id in (?) AND created_at > ?', ids, since], 
      :order => 'created_at DESC',
      :page => page)      
  end
  
  def self.recent_activity(page = {})
    page.reverse_merge :size => 10, :current => 1
    
    Activity.find(:all, 
      :order => 'created_at DESC',
      :page => page)      
  end
  
  def friends_ids
    return [] if accepted_friendships.empty?
    accepted_friendships.map{|fr| fr.friend_id }
  end
  
  def recommended_posts(since = 1.week.ago)
    return [] if tags.empty?
    rec_posts = Post.find_tagged_with(tags.map(&:name), 
      :conditions => ['posts.user_id != ? AND published_at > ?', self.id, since ],
      :order => 'published_at DESC',      
      :limit => 10
      )

    if rec_posts.empty?
      []
    else
      rec_posts.uniq
    end
  end
  
  def display_name
    login
  end
  
  def admin?
    role && role.eql?(Role[:admin])
  end
  def moderator?
    role && role.eql?(Role[:moderator])
  end
  def member?
    role && role.eql?(Role[:member])
  end
  


  #from savage beast
  def self.currently_online
    User.find(:all, :conditions => ["sb_last_seen_at > ?", Time.now.utc-5.minutes])
  end
  def self.search(query, options = {})
    with_scope :find => { :conditions => build_search_conditions(query) } do
      find :all, options
    end
  end
  def self.build_search_conditions(query)
    # query && ['LOWER(display_name) LIKE :q OR LOWER(login) LIKE :q', {:q => "%#{query}%"}]
    query
  end


  protected
  # If you're going to use activation, uncomment this too
  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  # before filters
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def whitelist_attributes
    self.description = white_list(self.description )
    self.stylesheet = white_list(self.stylesheet )
  end
  
  def password_required?
    crypted_password.blank? || !password.blank?
  end
  
end
