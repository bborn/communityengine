class Role < ActiveRecord::Base
  acts_as_enumerated
  validates_presence_of :name  
  attr_accessible :name
end

