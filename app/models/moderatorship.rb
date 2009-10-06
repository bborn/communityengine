class Moderatorship < ActiveRecord::Base
  belongs_to :forum
  belongs_to :user
  validates_presence_of :user, :forum
  
  before_create { |r| count(:all, :conditions => ['forum_id = ? and user_id = ?', r.forum_id, r.user_id]).zero? }
end
