class Album < ActiveRecord::Base
  has_many :photos, :dependent => :destroy
  belongs_to :user
  validates_presence_of :user_id
  acts_as_activity :user
  acts_as_commentable
  validates_presence_of :title  

  def owner
    self.user
  end
end
