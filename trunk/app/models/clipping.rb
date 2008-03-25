class Clipping < ActiveRecord::Base
  include ActionController::UrlWriter
  default_url_options[:host] = APP_URL.sub('http://', '')

  acts_as_commentable
  belongs_to :user
  validates_presence_of :user
  validates_presence_of :url
  validates_presence_of :image_url

  after_create :get_clipping_image
  
  has_one :image, :as => :attachable, :dependent => :destroy, :class_name => "ClippingImage"  
  has_many :favorites, :as => :favoritable, :dependent => :destroy
  
  acts_as_taggable
  acts_as_activity :user
    
  def self.find_related_to(clipping, options = {})
    merged_options = options.merge({:limit => 8, 
        :order => 'created_at DESC', 
        :sql => " AND clippings.id != '#{clipping.id}' GROUP BY clippings.id"})
    clippings = find_tagged_with(clipping.tags.collect{|t| t.name }, merged_options)
  end

  def self.find_recent(options = {:limit => 5})
    find(:all, :conditions => "created_at > '#{7.days.ago.to_s :db}'", :order => "created_at DESC", :limit => options[:limit])
  end

  def previous_clipping
    self.user.clippings.find(:first, :conditions => ['created_at < ?', self.created_at], :order => 'created_at DESC')
  end
  def next_clipping
    self.user.clippings.find(:first, :conditions => ['created_at > ?', self.created_at], :order => 'created_at ASC')
  end

  def owner
    self.user
  end
  
  def image_uri(size = '')
    image && image.public_filename(size) || image_url
  end
  
  def title_for_rss
    description.empty? ? created_at.to_formatted_s(:long) : description
  end
  
  def description_for_rss
    "<a href='#{link_for_rss}' title='#{title_for_rss}'><img src='#{image_url}' alt='#{description}' /></a>"
  end

  def link_for_rss
    user_clipping_url(self.user, self)
  end
  
  def has_been_favorited_by(user = nil, remote_ip = nil)
    f = Favorite.find_by_user_or_ip_address(self, user, remote_ip)
    return f
  end
  
  # private
  def get_clipping_image
    begin
      uploaded_data = UrlUpload.new(self.image_url)
      clipping_image = ClippingImage.find_or_create_by_attachable_id(self.id)
      clipping_image.uploaded_data = uploaded_data
      clipping_image.attachable = self.reload
      clipping_image.save
    rescue
      nil
    end
  end

end