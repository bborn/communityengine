class AddFriendshipStatuses < ActiveRecord::Migration
  def self.up
    FriendshipStatus.enumeration_model_updates_permitted = true    
    FriendshipStatus.create :name => "pending"
    FriendshipStatus.create :name => "accepted"
    FriendshipStatus.enumeration_model_updates_permitted = false
  end

  def self.down
    FriendshipStatus.enumeration_model_updates_permitted = true    
    FriendshipStatus.destroy_all
    FriendshipStatus.enumeration_model_updates_permitted = false
  end
end
