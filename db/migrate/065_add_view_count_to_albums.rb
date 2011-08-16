class AddViewCountToAlbums < ActiveRecord::Migration
  def self.up
    add_column :albums, :view_count, :integer
  end

  def self.down
    remove_column :albums, :view_count
  end
end
