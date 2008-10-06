class Skill < ActiveRecord::Base
  has_many :offerings
  has_many :users, :through => :offerings
  validates_uniqueness_of :name

  def to_param
    id.to_s << "-" << (name ? name.gsub(/[^a-z1-9]+/i, '-') : '' )
  end
  
end
