class AddMoreIndexes < ActiveRecord::Migration
  def self.up
    add_index :posts, :published_at
    add_index :posts, :published_as
    add_index :polls, :created_at    
    add_index :polls, :post_id
    add_index :activities, :created_at
    add_index :activities, :user_id
  end
  
  def self.down
    remove_index :posts, :published_at
    remove_index :posts, :published_as        
    remove_index :polls, :created_at    
    remove_index :polls, :post_id        
    remove_index :activities, :created_at
    remove_index :activities, :user_id
  end  
end
