class TrackEmailed < ActiveRecord::Migration
  def self.up
    add_column :posts, :emailed_count, :integer, :default => 0
  end

  def self.down
    remove_column :posts, :emailed_count
  end
end
