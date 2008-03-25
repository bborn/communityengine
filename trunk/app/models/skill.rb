class Skill < ActiveRecord::Base
  has_many :offerings
  validates_uniqueness_of :name

  def to_param
    id.to_s << "-" << (name ? name.gsub(/[^a-z1-9]+/i, '-') : '' )
  end
  
  def users
    self.offerings.collect{ |o| o.user }.select{ |u| u.vendor? }
  end
end
