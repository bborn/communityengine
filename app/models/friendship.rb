class Friendship < ActiveRecord::Base
  include ActionController::UrlWriter
  default_url_options[:host] = APP_URL.sub('http://', '')

  @@daily_request_limit = 12
  cattr_accessor :daily_request_limit

  belongs_to :user
  belongs_to :friend, :class_name => "User", :foreign_key => "friend_id"   
  has_enumerated :friendship_status, :class_name => 'FriendshipStatus', :foreign_key => 'friendship_status_id'

  validates_presence_of   :friendship_status
  validates_presence_of   :user
  validates_presence_of   :friend
  validates_uniqueness_of :friend_id, :scope => :user_id

  validates_each :user_id do |record, attr, value|
    record.errors.add attr, 'can not be same as friend' if record.user_id.eql?(record.friend_id)
  end
  
  def validate  
    if new_record? && initiator && user.has_reached_daily_friend_request_limit?
      errors.add_to_base("Sorry, you'll have to wait a little while before requesting any more friendships.")       
    end
  end  
    
  before_validation_on_create :set_pending

  attr_protected :friendship_status_id
  
  def reverse
    Friendship.find(:first, :conditions => ['user_id = ? and friend_id = ?', self.friend_id, self.user_id])
  end
  
  def generate_url
    pending_user_friendships_url(self.friend)    
  end

  def denied?
    friendship_status.eql?(FriendshipStatus[:denied])
  end
  
  def pending?
    friendship_status.eql?(FriendshipStatus[:pending])
  end
  
  def self.friends?(user, friend)
    find(:first, :conditions => ["user_id = ? AND friend_id = ? AND friendship_status_id = ?", user.id, friend.id, FriendshipStatus[:accepted].id ])
  end
    
  private
  def set_pending
    friendship_status_id = FriendshipStatus[:pending].id
  end  
end
