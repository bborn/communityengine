class Clipping < ActiveRecord::Base

  acts_as_commentable
  belongs_to :user
  validates_presence_of :user
  validates_presence_of :url
  validates_presence_of :image_url

  before_validation :add_image
  validates_associated :image
  validates_presence_of :image
  after_save :save_image
  
  has_one  :image, :as => :attachable, :class_name => "ClippingImage", :dependent => :destroy
  has_many :favorites, :as => :favoritable, :dependent => :destroy
  
  acts_as_taggable
  acts_as_activity :user

  attr_accessible :user, :url, :description, :image_url
    
  scope :recent, :order => 'clippings.created_at DESC'    
    
    
  def self.find_related_to(clipping, options = {})
    options.reverse_merge!({:limit => 8, 
        :order => 'created_at DESC',
        :conditions => [ 'clippings.id != ?', clipping.id ]
    })

    limit(options[:limit]).
      order(options[:order]).
      where(options[:conditions]).
      tagged_with(clipping.tags.collect{|t| t.name }, :any => true)
  end

  def self.find_recent(options = {:limit => 5})
    find(:all, :conditions => "created_at > '#{7.days.ago.iso8601}'", :order => "created_at DESC", :limit => options[:limit])
  end

  def previous_clipping
    self.user.clippings.order('created_at DESC').where('created_at < ?', self.created_at).first
  end
  def next_clipping
    self.user.clippings.where('created_at > ?', self.created_at).order('created_at ASC').first    
  end

  def owner
    self.user
  end
  
  def image_uri(size = '')
    image && image.asset.url(size) || image_url
  end
  
  def title_for_rss
    description.empty? ? created_at.to_formatted_s(:long) : description
  end

  def has_been_favorited_by(user = nil, remote_ip = nil)
    f = Favorite.find_by_user_or_ip_address(self, user, remote_ip)
    return f
  end
  
  def add_image
    begin
      clipping_image = ClippingImage.new
      uploaded_data = clipping_image.data_from_url(self.image_url)
      clipping_image.asset = uploaded_data
      self.image = clipping_image
    rescue
      nil
    end
  end
  
  def save_image
    if valid? && image
      image.attachable = self
      image.save
    end
  end

end
