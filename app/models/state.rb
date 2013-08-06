class State < ActiveRecord::Base
  has_many :metro_areas
  # belongs_to :country

  attr_accessible :name
end
