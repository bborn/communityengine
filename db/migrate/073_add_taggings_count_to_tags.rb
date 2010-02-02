class AddTaggingsCountToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :taggings_count, :integer, :default => 0
  end
  
  def self.down
    remove_column :tags, :taggings_count
  end
end
