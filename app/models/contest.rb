class Contest < ActiveRecord::Base
  has_many :posts, :order => "published_at desc"
  before_save :transform_post

  validates_presence_of :begin, :end, :title, :banner_title, :banner_subtitle
  

  def transform_post
    #self.post = Post.convert_to_html(self.raw_post, 'textile')
    self.post = white_list(self.raw_post)
  end
  
  def self.get_active
    Contest.find(:first, :conditions => "begin < '#{Time.now.to_s :db}' and end > '#{Time.now.to_s :db}'", :order => 'created_at desc')
  end
  
  def active?
    (self.begin < Time.now ) and (self.end > Time.now )
  end
  
end
