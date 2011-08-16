class Moderatorship < ActiveRecord::Base
  belongs_to :forum
  belongs_to :user
  validates_presence_of :user, :forum

  validates_uniqueness_of :user_id, :scope => :forum_id

end
