require "uri"    
    
class Post < ActiveRecord::Base
  include ActionController::UrlWriter
  default_url_options[:host] = APP_URL.sub('http://', '')

  acts_as_commentable
  acts_as_taggable
  acts_as_activity :user
  acts_as_publishable :live, :draft

  belongs_to :user
  belongs_to :category
  belongs_to :contest
  has_many   :polls, :dependent => :destroy
  has_many :favorites, :as => :favoritable, :dependent => :destroy
  
  validates_presence_of :raw_post
  validates_presence_of :title
  validates_presence_of :user

  before_save :transform_post
  attr_accessor :invalid_emails

  def self.find_related_to(post, options = {})
    merged_options = options.merge({:limit => 8, 
        :order => 'created_at DESC', 
        :sql => " AND posts.id != '#{post.id}' GROUP BY posts.id"})
    posts = find_tagged_with(post.tags.collect{|t| t.name }, merged_options)
  end


  def to_param
    id.to_s << "-" << (title ? title.gsub(/[^a-z1-9]+/i, '-') : '' )
  end
  
  def link_for_rss
    user_post_url(self.user, self)
  end
  
  def self.find_recent(options = {:limit => 5})
    find(:all, :order => "created_at desc", :limit => options[:limit])
  end
  
  def self.find_popular(options = {} )
    options.reverse_merge! :limit => 5, :since => 7.days
    find(:all, :conditions => "created_at > '#{options[:since].ago.to_s :db}'", :order => "view_count desc", :limit => options[:limit])
  end

  def self.find_featured(options = {:limit => 10})
    find(:all, :order => "posts.created_at desc", :conditions => ["users.featured_writer = ?", true], :limit => options[:limit], :include => :user)    
  end

  def self.find_most_commented(limit = 10, since = 7.days.ago)
    Post.find(:all, 
      :select => 'posts.*, count(*) as comments_count',
      :joins => "LEFT JOIN comments ON comments.commentable_id = posts.id",
      :conditions => ['comments.commentable_type = ? AND posts.created_at > ?', 'Post', since],
      :group => 'comments.commentable_id',
      :order => 'comments_count DESC',
      :limit => limit
      )
  end

  def display_title
    t = self.title
    if self.category
      t = self.category.name.upcase << ": " << t
    end
    t
  end
  
  def previous_post
    self.user.posts.find(:first, :conditions => ['created_at < ?', created_at], :order => 'created_at DESC')
  end
  def next_post
    self.user.posts.find(:first, :conditions => ['created_at > ?', created_at], :order => 'created_at ASC')
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
   # self.raw_post  = force_relative_urls(self.raw_post)
   self.post  = white_list(self.raw_post)
   self.title = white_list(self.title)
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
        UserNotifier.deliver_post_recommendation((user ? user.login : 'Someone'), email, self, message, user)
      }
      self.increment(:emailed_count).save    
    end
  end
  
  def self.new_from_bookmarklet(params)
    self.new(
      :title => "#{params[:title] || params[:uri]}",
      :raw_post => "<a href='#{params[:uri]}'>#{params[:uri]}</a>#{params[:selection] ? "<p>#{params[:selection]}</p>" : ''}"
      )
  end
  
  def image_for_excerpt
    first_image_in_body || user.avatar_photo_url(:medium)  
  end
  
  def create_poll(poll, choices)
    new_poll = self.polls.build(:question => poll[:question])
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
      
end
