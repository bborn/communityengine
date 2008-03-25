class ChangeCommentToTextField < ActiveRecord::Migration
  def self.up
    change_column "comments", "comment", :text, :default => ""
  end

  def self.down
    change_column "comments", "comment", :string, :default => ""
  end
end
