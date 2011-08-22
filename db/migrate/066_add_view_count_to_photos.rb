class AddViewCountToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :view_count, :integer
  end

  def self.down
    remove_column :photos, :view_count
  end
end
