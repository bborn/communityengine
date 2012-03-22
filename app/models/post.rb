class Post < ActiveRecord::Base
  include Rakismet::Model
  rakismet_attrs :comment_type => 'post'
  attr_protected :akismet_attrs  
  
  
  acts_as_commentable
  acts_as_taggable
  acts_as_activity :user, :if => Proc.new{|r| r.is_live?}
  acts_as_publishable :live, :draft
  
  belongs_to :user
  belongs_to :category
  has_many   :polls, :dependent => :destroy
  has_many :favorites, :as => :favoritable, :dependent => :destroy
  
  validates_presence_of :raw_post
  validates_presence_of :title
  validates_presence_of :user
  validates_presence_of :published_at, :if => Proc.new{|r| r.is_live? }
  
  before_save :transform_post
  before_validation :set_published_at
  
  after_save do |post|
    activity = Activity.find_by_item_type_and_item_id('Post', post.id)
    if post.is_live? && !activity
      post.create_activity_from_self 
    elsif post.is_draft? && activity
      activity.destroy
    end
  end
    
  attr_accessor :invalid_emails
  
  # Class Methods
  class << self
    
    # Scopes    
    def by_featured_writers
      where("users.featured_writer = ?", true).includes(:user)
    end
    def popular
      order('posts.view_count DESC')
    end
    def since(days)
      where("posts.published_at > ?", days.ago)    
    end
    def recent
      order("posts.published_at DESC")    
    end
  
    def find_related_to(post, options = {})
      options.reverse_merge!({:limit => 8, 
          :order => 'published_at DESC', 
          :conditions => [ 'posts.id != ? AND published_as = ?', post.id, 'live' ]
      })

      limit(options[:limit]).order(options[:order]).where(options[:conditions]).tagged_with(post.tag_list, :any => true)
    end
    
    def find_recent(options = {:limit => 5})
      recent.find :all, options
    end

    def find_popular(options = {} )
      options.reverse_merge! :limit => 5, :since => 7.days

      self.popular.since(options[:since]).limit(options[:limit]).all
    end

    def find_featured(options = {:limit => 10})
      self.recent.by_featured_writers.limit(options[:limit]).all
    end

    def find_most_commented(limit = 10, since = 7.days.ago)
      Post.find(:all, 
        :select => 'posts.*, count(*) as comments_count',
        :joins => "LEFT JOIN comments ON comments.commentable_id = posts.id",
        :conditions => ['comments.commentable_type = ? AND posts.published_at > ?', 'Post', since],
        :group => self.columns.map{|column| self.table_name + "." + column.name}.join(","),
        :order => 'comments_count DESC',
        :limit => limit
        )
    end    
    
    def new_from_bookmarklet(params)
      self.new(
        :title => "#{params[:title] || params[:uri]}",
        :raw_post => "<a href='#{params[:uri]}'>#{params[:uri]}</a>#{params[:selection] ? "<p>#{params[:selection]}</p>" : ''}"
        )
    end
  
  end
  
  

  
  def to_param
    id.to_s << "-" << (title ? title.parameterize : '' )
  end
  
  def display_title
    t = self.title
    if self.category
      t = self.category.name.upcase << ": " << t
    end
    t
  end
  
  def previous_post
    self.user.posts.order('published_at DESC').where('published_at < ? and published_as = ?', published_at, 'live').first
  end
  def next_post
    self.user.posts.except(:order).order('published_at DESC').where('published_at > ? and published_as = ?', published_at, 'live').first    
  end
  
  def first_image_in_body(size = nil, options = {})
    doc = Hpricot( post )
    image = doc.at("img")
    image ? image['src'] : nil
  end
  
  def tag_for_first_image_in_body
    image = first_image_in_body
    image.nil? ? '' : "<img src='#{image}' />"
  end
  
  ## transform the text and title into valid html
  def transform_post
   self.post  = white_list(self.raw_post)
   self.title = white_list(self.title)
  end
  
  def set_published_at
    if self.is_live? && !self.published_at
      self.published_at = Time.now
    end
  end
  
  def owner
    self.user
  end
  
  def send_to(email_addresses = '', message = '', user = nil)
    self.invalid_emails = []
    emails = email_addresses.split(",").collect{|email| email.strip }.uniq
    emails.each do |email|      
      self.invalid_emails << email unless email =~ /[\w._%-]+@[\w.-]+.[a-zA-Z]{2,4}/
    end
    if email_addresses.blank? || !invalid_emails.empty?
      return false
    else    
      emails = email_addresses.split(",").collect{|email| email.strip }.uniq 
      emails.each{|email|
        UserNotifier.post_recommendation((user ? user.login : 'Someone'), email, self, message, user).deliver
      }
      self.increment(:emailed_count).save    
    end
  end
    
  def image_for_excerpt
    first_image_in_body || user.avatar_photo_url(:medium)  
  end
  
  def create_poll(poll, choices)
    new_poll = self.polls.new(:question => poll[:question])
    choices.delete('')
    if choices.size > 1
      new_poll.save
      new_poll.add_choices(choices)
    end
  end
  
  def update_poll(poll, choices)
    return unless self.poll
    self.poll.update_attributes(:question => poll[:question])
    choices.delete('')
    if choices.size > 1
      self.poll.choices.destroy_all
      self.poll.save
      self.poll.add_choices(choices)
    else
      self.poll.destroy
    end
  end
  
  def poll
    !polls.empty? && polls.first
  end
  
  def has_been_favorited_by(user = nil, remote_ip = nil)
    f = Favorite.find_by_user_or_ip_address(self, user, remote_ip)
    return f
  end  
  
  def published_at_display(format = :published_date)
    is_live? ? I18n.l(published_at, :format => format.to_sym) : 'Draft'
  end
      
end
