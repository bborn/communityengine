class HomepageFeature < ActiveRecord::Base  
  has_attachment prepare_options_for_attachment_fu(AppConfig.feature['attachment_fu_options'])

  validates_presence_of
  validates_presence_of :content_type
  validates_presence_of :filename
  validates_presence_of :url, :if => Proc.new{|record| record.parent.nil? }
  
  def self.find_features
    find(:all, :order => "created_at DESC", :conditions => 'parent_id IS NULL')
  end

end
