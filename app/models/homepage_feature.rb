class HomepageFeature < ActiveRecord::Base  
  has_attached_file :homepage_feature_file, default_s3_options.merge(
    :storage => :s3,
    :styles => { :original => '465>', :thumb => "45x45#", :large => "635x150#" },
    :path => "/:attachment/:id/:basename:maybe_style.:extension")
  validates_attachment_presence :homepage_feature_file
  validates_attachment_content_type :homepage_feature_file, :content_type => ['image/jpg', 'image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png']
  validates_attachment_size :homepage_feature_file, :less_than => 1.megabytes

  attr_accessible :url, :title, :description

  validates_presence_of :url
  
  def self.find_features
    find(:all, :order => "created_at DESC")
  end

end
