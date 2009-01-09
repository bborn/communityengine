class Contest < ActiveRecord::Base
  has_many :posts, :order => "published_at desc"
  before_save :transform_post

  validates_presence_of :begin, :end, :title, :banner_title, :banner_subtitle
  
  named_scope :active, :conditions => ["begin < ? AND end > ?", Time.now, Time.now], :order => 'created_at desc'

  def self.current
    active.find(:first)
  end

  def transform_post
    self.post = white_list(self.raw_post)
  end
  
  def self.get_active
    Contest.find(:first, :conditions => ["begin < ? AND end > ?", Time.now, Time.now], :order => 'created_at desc')
  end
  
  def active?
    (self.begin < Time.now ) and (self.end > Time.now )
  end

  def time_and_date
    if spans_days?
      string = "#{start_time.strftime("%B %d")} to #{end_time.strftime("%B %d %Y")}"
    else
      string = "#{start_time.strftime("%B %d, %Y")}, #{start_time.strftime("%I:%M %p")} - #{end_time.strftime("%I:%M %p")}"
    end
  end

  def spans_days?
    (end_time - start_time) >= 86400
  end
  
  def start_time
    self.begin
  end
  
  def end_time
    self.end
  end

  
end
