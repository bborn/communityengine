class Offering < ActiveRecord::Base
  belongs_to :user
  belongs_to :skill
  validates_presence_of :skill
  validates_presence_of :user

end
