class HomepageFeature < ActiveRecord::Base  
  has_attached_file :image, configatron.feature.paperclip_options.to_hash
  validates_attachment_presence :image, :message => :photo_presence_error.l
  validates_attachment_content_type :image, :content_type => configatron.feature.validation_options.content_type, :message => :photo_content_type_error.l
  validates_attachment_size :image, :less_than => configatron.feature.validation_options.max_size.to_i.megabytes, :message => :photo_size_limit_error.l(:count => configatron.feature.validation_options.max_size)

  attr_accessible :url, :title, :description, :image

  validates_presence_of :url
  
  def self.find_features
    find(:all, :order => "created_at DESC")
  end

end
