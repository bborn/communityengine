class HomepageFeature < ActiveRecord::Base  
  has_attachment prepare_options_for_attachment_fu(configatron.feature.attachment_fu_options.to_hash)
  attr_accessible :url, :title, :description, :position

  validates_presence_of :content_type
  validates_presence_of :filename
  validates_presence_of :url, :if => Proc.new{|record| record.parent.nil? }
  
  def self.find_features
    find(:all, :order => "created_at DESC", :conditions => 'parent_id IS NULL')
  end

end
