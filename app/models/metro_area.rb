class MetroArea < ActiveRecord::Base
  has_many :users
  belongs_to :state
  belongs_to :country

  #validates_presence_of :state, :if => Proc.new { |user| user.country.eql?(Country.get(:us)) }
  validates_presence_of :country
  validates_presence_of :name

end
