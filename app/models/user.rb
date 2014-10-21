require 'digest/sha1'
require 'bcrypt'

class User < ActiveRecord::Base
  include UrlUpload
  include FacebookProfile
  include TwitterProfile

  include Rakismet::Model
  rakismet_attrs :author => :login, :comment_type => 'registration', :content => :description, :user_ip => :last_login_ip, :author_email => :email
  attr_protected :admin, :featured, :role_id, :akismet_attrs

  has_friendly_id :login, :use_slug => true, :cache_column => 'login_slug'

  MALE    = 'M'
  FEMALE  = 'F'

  begin
    acts_as_authentic do |c|
      c.transition_from_crypto_providers = CommunityEngineSha1CryptoMethod
      c.crypto_provider = Authlogic::CryptoProviders::BCrypt

      c.validates_length_of_password_field_options = { :within => configatron.authlogic.password_length, :if => :password_required? }
      c.validates_length_of_password_confirmation_field_options = { :within => configatron.authlogic.password_length, :if => :password_required? }

      c.validates_length_of_login_field_options = { :within => configatron.authlogic.login_length, :unless => :omniauthed? }
      c.validates_format_of_login_field_options = { :with => configatron.regexes.login, :unless => :omniauthed? }

      c.validates_length_of_email_field_options = { :within => configatron.authlogic.email_length, :if => :email_required? }
      c.validates_format_of_email_field_options = { :with => configatron.regexes.email, :if => :email_required? }
      c.validates_uniqueness_of_email_field_options :case_sensitive => configatron.authlogic.email_case_sensitive
    end
  rescue StandardError
    puts 'Failed to initialize AuthLogic'
  end

  acts_as_taggable
  acts_as_moderated_commentable
  has_enumerated :role
  tracks_unlinked_activities [:logged_in, :invited_friends, :updated_profile, :joined_the_site]

  #callbacks
  before_create :make_activation_code
  after_create  :update_last_login
  after_create  :deliver_signup_notification
  before_save   :whitelist_attributes
  after_save    :recount_metro_area_users
  after_destroy :recount_metro_area_users

  #validation
  validates_presence_of     :metro_area, :if => Proc.new { |user| user.state }
  validates_uniqueness_of   :login, :if => :requires_unique_login?
  validates_exclusion_of    :login, :in => Proc.new{ configatron.reserved_logins }

  validate :valid_birthday, :if => :requires_valid_birthday?
  validate :check_spam

  #associations
    has_many :authorizations, :dependent => :destroy
    has_many :posts, :order => "published_at desc", :dependent => :destroy
    has_many :photos, :order => "created_at desc", :dependent => :destroy
    has_many :invitations, :dependent => :destroy
    has_many :rsvps, :dependent => :destroy
    has_many :albums, :dependent => :destroy

    #friendship associations
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

    belongs_to  :avatar, :class_name => "Photo", :foreign_key => "avatar_id", :inverse_of => :user_as_avatar
    belongs_to  :metro_area, :counter_cache => true
    belongs_to  :state
    belongs_to  :country
    has_many    :comments_as_author, :class_name => "Comment", :foreign_key => "user_id", :order => "created_at desc", :dependent => :destroy
    has_many    :comments_as_recipient, :class_name => "Comment", :foreign_key => "recipient_id", :order => "created_at desc", :dependent => :destroy
    has_many    :clippings, :order => "created_at desc", :dependent => :destroy
    has_many    :favorites, :order => "created_at desc", :dependent => :destroy

    #messages
    has_many :all_sent_messages, :class_name => "Message", :foreign_key => "sender_id", :dependent => :destroy
    has_many :sent_messages,
             :class_name => 'Message',
             :foreign_key => 'sender_id',
             :order => "messages.created_at DESC",
             :conditions => ["messages.sender_deleted = ?", false]

    has_many :received_messages,
             :class_name => 'Message',
             :foreign_key => 'recipient_id',
             :order => "messages.created_at DESC",
             :conditions => ["messages.recipient_deleted = ?", false]
    has_many :message_threads_as_recipient, :class_name => "MessageThread", :foreign_key => "recipient_id"

  #named scopes
  scope :recent, order('users.created_at DESC')
  scope :featured, where(:featured_writer => true)
  scope :active, where("users.activated_at IS NOT NULL")
  scope :vendors, where(:vendor => true)


  accepts_nested_attributes_for :avatar
  attr_accessible :avatar_id, :company_name, :country_id, :description, :email,
    :firstname, :fullname, :gender, :lastname, :login, :metro_area_id,
    :middlename, :notify_comments, :notify_community_news,
    :notify_friend_requests, :password, :password_confirmation,
    :profile_public, :state_id, :stylesheet, :time_zone, :vendor, :zip, :avatar_attributes, :birthday,
    :activated_at, :activation_code

  attr_accessor :authorizing_from_omniauth

  ## Class Methods

  def self.find_by_login_or_email(string)
    self.first(:conditions => ["LOWER(email) = ? OR LOWER(login) = ?", string.downcase, string.downcase])
  end

  def self.find_country_and_state_from_search_params(search)
    country     = Country.find(search['country_id']) if !search['country_id'].blank?
    state       = State.find(search['state_id']) if !search['state_id'].blank?
    metro_area  = MetroArea.find(search['metro_area_id']) if !search['metro_area_id'].blank?

    if metro_area && metro_area.country
      country ||= metro_area.country
      state   ||= metro_area.state
      search['country_id'] = metro_area.country.id if metro_area.country
      search['state_id'] = metro_area.state.id if metro_area.state
    end

    states  = country ? country.states.sort_by{|s| s.name} : []
    if states.any?
      metro_areas = state ? state.metro_areas.all(:order => "name") : []
    else
      metro_areas = country ? country.metro_areas : []
    end

    return [metro_areas, states]
  end

  def self.prepare_params_for_search(params)
    search = {}.merge(params)
    search['metro_area_id'] = params[:metro_area_id] || nil
    search['state_id'] = params[:state_id] || nil
    search['country_id'] = params[:country_id] || nil
    search
  end

  def self.build_conditions_for_search(search)
    user = User.arel_table
    users = User.active
    if search['country_id'] && !(search['metro_area_id'] || search['state_id'])
      users = users.where(user[:country_id].eq(search['country_id']))
    end
    if search['state_id'] && !search['metro_area_id']
      users = users.where(user[:state_id].eq(search['state_id']))
    end
    if search['metro_area_id']
      users = users.where(user[:metro_area_id].eq(search['metro_area_id']))
    end
    if search['login']
      users = users.where(user[:login].matches("%#{search['login']}%"))
    end
    if search['vendor']
      users = users.where(user[:vendor].eq(true))
    end
    if search['description']
      users = users.where(user[:description].matches("%#{search['description']}%"))
    end
    users
  end

  def self.find_by_activity(options = {})
    options.reverse_merge! :limit => 30, :require_avatar => true, :since => 7.days.ago

    activities = Activity.since(options[:since]).find(:all,
      :select => 'activities.user_id, count(*) as count',
      :group => 'activities.user_id',
      :conditions => "#{options[:require_avatar] ? ' users.avatar_id IS NOT NULL AND ' : ''} users.activated_at IS NOT NULL",
      :order => 'count DESC',
      :joins => "LEFT JOIN users ON users.id = activities.user_id",
      :limit => options[:limit]
      )
    activities.map{|a| find(a.user_id) }
  end

  def self.find_featured
    self.featured
  end

  def self.search_conditions_with_metros_and_states(params)
    search = prepare_params_for_search(params)

    metro_areas, states = find_country_and_state_from_search_params(search)

    users = build_conditions_for_search(search)
    return users, search, metro_areas, states
  end


  def self.recent_activity(options = {})
    options.reverse_merge! :per_page => 10, :page => 1
    Activity.recent.joins("LEFT JOIN users ON users.id = activities.user_id").where('users.activated_at IS NOT NULL').select('activities.*').page(options[:page]).per(options[:per_page])
  end

  def self.currently_online
    User.find(:all, :conditions => ["sb_last_seen_at > ?", Time.now.utc-5.minutes])
  end

  def self.search(query, options = {})
    with_scope :find => { :conditions => build_search_conditions(query) } do
      find :all, options
    end
  end

  def self.build_search_conditions(query)
    query
  end

  ## End Class Methods


  ## Instance Methods

  def moderator_of?(forum)
    moderatorships.count(:all, :conditions => ['forum_id = ?', (forum.is_a?(Forum) ? forum.id : forum)]) == 1
  end

  def monitoring_topic?(topic)
    monitored_topics.find_by_id(topic.id)
  end

  def recount_metro_area_users
    return unless self.metro_area
    ma = self.metro_area
    ma.users_count = User.count(:conditions => ["metro_area_id = ?", ma.id])
    ma.save
  end

  def this_months_posts
    self.posts.find(:all, :conditions => ["published_at > ?", DateTime.now.to_time.at_beginning_of_month])
  end

  def last_months_posts
    self.posts.find(:all, :conditions => ["published_at > ? and published_at < ?", DateTime.now.to_time.at_beginning_of_month.months_ago(1), DateTime.now.to_time.at_beginning_of_month])
  end

  def avatar_photo_url(size = :original)
    if avatar_id
      avatar.photo.url(size)
    elsif facebook?
      facebook_authorization.picture_url
    elsif twitter?
      twitter_authorization.picture_url
    else
      case size
        when :thumb
          configatron.photo.missing_thumb.to_s
        else
          configatron.photo.missing_medium.to_s
      end
    end
  end

  def deactivate
    return if admin? #don't allow admin deactivation
    User.transaction do
      update_attribute(:activated_at, nil)
      update_attribute(:activation_code, make_activation_code)
    end
  end

  def activate
    User.transaction do
      update_attribute(:activated_at, Time.now.utc)
      update_attribute(:activation_code, nil)
    end
    UserNotifier.activation(self).deliver
  end

  def active?
    activation_code.nil? && !activated_at.nil?
  end

  def valid_invite_code?(code)
    code == invite_code
  end

  def invite_code
    Digest::SHA1.hexdigest("#{self.id}--#{self.email}--#{self.password_salt}")
  end

  def location
    metro_area && metro_area.name || ""
  end

  def full_location
    "#{metro_area.name if self.metro_area}#{" , #{self.country.name}" if self.country}"
  end

  def reset_password
     new_password = newpass(8)
     self.password = new_password
     self.password_confirmation = new_password
     return self.valid?
  end

  def newpass( len )
     chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
     new_password = ""
     1.upto(len) { |i| new_password << chars[rand(chars.size-1)] }
     return new_password
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

  def deliver_signup_notification
    UserNotifier.signup_notification(self).deliver
  end

  def update_last_login
    self.track_activity(:logged_in) if self.active? && self.last_login_at.nil? || (self.last_login_at && self.last_login_at < Time.now.beginning_of_day)
    self.update_attribute(:last_login_at, Time.now)
  end

  def has_reached_daily_friend_request_limit?
    friendships_initiated_by_me.count(:conditions => ['created_at > ?', Time.now.beginning_of_day]) >= Friendship.daily_request_limit
  end

  def network_activity(page = {}, since = 1.week.ago)
    page.reverse_merge! :per_page => 10, :page => 1
    friend_ids = self.friends_ids
    metro_area_people_ids = self.metro_area ? self.metro_area.users.map(&:id) : []

    ids = ((friends_ids | metro_area_people_ids) - [self.id])[0..100] #don't pull TOO much activity for now

    Activity.recent.since(since).by_users(ids).page(page[:page]).per(page[:per_page])
  end

  def comments_activity(page = {}, since = 1.week.ago)
    page.reverse_merge :per_page => 10, :page => 1

    Activity.recent.since(since).where('comments.recipient_id = ? AND activities.user_id != ?', self.id, self.id).joins("LEFT JOIN comments ON comments.id = activities.item_id AND activities.item_type = 'Comment'").page(page[:per_page]).per(page[:page])
  end

  def friends_ids
    return [] if accepted_friendships.empty?
    accepted_friendships.map{|fr| fr.friend_id }
  end

  def recommended_posts(since = 1.week.ago)
    return [] if tags.empty?
    rec_posts = Post.tagged_with(tags.map(&:name), :any => true).where(['posts.user_id != ? AND published_at > ?', self.id, since ])
    rec_posts = rec_posts.order('published_at DESC').limit(10)
    rec_posts
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

  def male?
    gender && gender.eql?(MALE)
  end

  def female
    gender && gender.eql?(FEMALE)
  end

  def update_last_seen_at
    User.update_all ['sb_last_seen_at = ?', Time.now.utc], ['id = ?', self.id]
    self.sb_last_seen_at = Time.now.utc
  end

  def unread_messages?
    unread_message_count > 0 ? true : false
  end

  def unread_message_count
    message_threads_as_recipient.count(:conditions => ["messages.recipient_id = ? AND messages.recipient_deleted = ? AND read_at IS NULL", self.id, false], :include => :message)
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    UserNotifier.password_reset_instructions(self).deliver
  end

  def valid_birthday
    date = configatron.min_age.years.ago
    errors.add(:birthday, "must be before #{date.strftime("%Y-%m-%d")}") unless birthday && (birthday.to_date <= date.to_date)
  end

  def self.find_or_create_from_authorization(auth)
    user = User.find_or_initialize_by_email(:email => auth.email)
    user.login ||= auth.nickname

    if user.new_record?
      new_password = user.newpass(8)
      user.password = new_password
      user.password_confirmation = new_password
    end

    user.authorizing_from_omniauth = true

    if user.save
      user.activate unless user.active?
      user.reset_persistence_token!
    end
    user
  end

  def check_spam
    if !configatron.akismet_key.nil? && self.spam?
      self.errors.add(:base, :user_spam_error.l)
    end
  end


  ## End Instance Methods

  protected

    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end

    # before filters
    def whitelist_attributes
      self.login = self.login.strip
      self.description = white_list(self.description )
      self.stylesheet = white_list(self.stylesheet )
    end

    def password_required?
      crypted_password.blank? || !password.blank?
    end

    def email_required?
      !omniauthed?
    end

    def requires_valid_birthday?
      !omniauthed?
    end

    def requires_unique_login?
      true
    end

    def omniauthed?
      authorizing_from_omniauth || authorizations.any?
    end

end
