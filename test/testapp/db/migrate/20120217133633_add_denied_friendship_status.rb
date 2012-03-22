class AddDeniedFriendshipStatus < ActiveRecord::Migration
  def self.up
    FriendshipStatus.enumeration_model_updates_permitted = true    
    FriendshipStatus.create :name => "denied"
    FriendshipStatus.enumeration_model_updates_permitted = false
  end

  def self.down
    FriendshipStatus.enumeration_model_updates_permitted = true    
    FriendshipStatus.find_by_name('denied').destroy
    FriendshipStatus.enumeration_model_updates_permitted = false
  end
end
