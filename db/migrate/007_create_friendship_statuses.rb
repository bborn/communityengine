class CreateFriendshipStatuses < ActiveRecord::Migration
  def self.up
    create_table :friendship_statuses do |t|
      t.column :name, :string
    end
    add_column "friendships", "friendship_status_id", :integer
  end

  def self.down
    drop_table :friendship_statuses
    remove_column "friendships", "friendship_status_id"
  end
end
