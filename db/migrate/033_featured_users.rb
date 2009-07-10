class FeaturedUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :featured_writer, :boolean, :default => false
  end

  def self.down
    remove_column :users, :featured_writer
  end
end
