class ChangeCommentToTextField < ActiveRecord::Migration
  def self.up
    remove_column "comments", "comment"
    add_column "comments", "comment", :text        
  end

  def self.down
    change_column "comments", "comment", :string, :default => ""
  end
end
