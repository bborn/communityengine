class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.column :friend_id, :integer
      t.column :user_id, :integer
      t.column "initiator", :boolean, :default => false
      t.column "created_at", :datetime
    end
  end

  def self.down
    drop_table :friendships
  end
end
