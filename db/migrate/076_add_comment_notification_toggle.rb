class AddCommentNotificationToggle < ActiveRecord::Migration
  def self.up
    add_column :posts, :send_comment_notifications, :boolean, :default => true
  end

  def self.down
    remove_column :posts, :send_comment_notifications
  end
end