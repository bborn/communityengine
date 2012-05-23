# This migration comes from community_engine (originally 8)
class AddFriendshipStatuses < ActiveRecord::Migration
  def self.up
    FriendshipStatus.enumeration_model_updates_permitted = true    
    FriendshipStatus.create({:name => "pending"}, :without_protection => true)
    FriendshipStatus.create({:name => "accepted"}, :without_protection => true)
    FriendshipStatus.enumeration_model_updates_permitted = false
  end

  def self.down
    FriendshipStatus.enumeration_model_updates_permitted = true    
    FriendshipStatus.destroy_all
    FriendshipStatus.enumeration_model_updates_permitted = false
  end
end
