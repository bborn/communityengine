class StillMoreIndexes < ActiveRecord::Migration
  def self.up
    add_index :posts, :user_id
    add_index :tags, :name    
    add_index :taggings, [:taggable_id, :taggable_type]
    add_index :photos, :created_at
    add_index :users, :created_at
    add_index :clippings, :created_at
  end

  def self.down
    remove_index :posts, :user_id        
    remove_index :tags, :name
    remove_index :taggings, :column => :taggable_id
    remove_index :photos, :created_at    
    remove_index :users, :created_at
    remove_index :clippings, :created_at
  end
end
