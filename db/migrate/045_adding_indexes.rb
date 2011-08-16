class AddingIndexes < ActiveRecord::Migration
  def self.up
    add_index :comments, :recipient_id
    add_index :photos, :parent_id
    add_index :taggings, :tag_id
    add_index :comments, :created_at
    add_index :users, :avatar_id
    add_index :users, :featured_writer    
    add_index :comments, :commentable_type
    add_index :comments, :commentable_id    
    add_index :taggings, :taggable_type
    add_index :taggings, :taggable_id    
    add_index :users, :activated_at
    add_index :users, :vendor
    add_index :posts, :category_id
    add_index :users, :login_slug
    add_index :friendships, :user_id
    add_index :friendships, :friendship_status_id  
  end

  def self.down
    remove_index :comments, :recipient_id
    remove_index :photos, :parent_id
    remove_index :taggings, :tag_id
    remove_index :comments, :created_at
    remove_index :users, :avatar_id
    remove_index :users, :featured_writer
    remove_index :comments, :commentable_type
    remove_index :comments, :commentable_id
    remove_index :taggings, :taggable_type
    remove_index :taggings, :taggable_id    
    remove_index :users, :activated_at
    remove_index :users, :vendor
    remove_index :posts, :category_id
    remove_index :users, :login_slug
    remove_index :friendships, :user_id
    remove_index :friendships, :friendship_status_id
  end
end
