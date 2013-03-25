class MetroArea < ActiveRecord::Base
  has_many :users
  belongs_to :state
  belongs_to :country

  attr_accessible :name, :state, :country_id, :state_id

  #validates_presence_of :state, :if => Proc.new { |user| user.country.eql?(Country.get(:us)) }
  validates_presence_of :country_id
  validates_presence_of :name

	acts_as_commentable

  def to_s
    name
  end

end
