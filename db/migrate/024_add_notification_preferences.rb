class AddNotificationPreferences < ActiveRecord::Migration
  def self.up
    add_column :users, :notify_comments, :boolean, :default => true
    add_column :users, :notify_friend_requests, :boolean, :default => true
    add_column :users, :notify_community_news, :boolean, :default => true
  end

  def self.down
    remove_column :users, :notify_comments
    remove_column :users, :notify_friend_requests
    remove_column :users, :notify_community_news
  end
end
