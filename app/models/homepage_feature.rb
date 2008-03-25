class HomepageFeature < ActiveRecord::Base  
  has_attachment  :storage => :s3, 
    :min_size         => 1,
    :max_size         => 1.megabytes,
    :content_type => ['image/jpg', 'image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png'],
    :thumbnails => AppConfig.feature['thumbs']

  validates_presence_of
  validates_presence_of :content_type
  validates_presence_of :filename
  validates_presence_of :url, :if => Proc.new{|record| record.parent.nil? }
  
  def self.find_features
    find(:all, :order => "created_at DESC", :conditions => 'parent_id IS NULL')
  end

end
