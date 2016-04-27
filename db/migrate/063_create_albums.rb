class CreateAlbums < ActiveRecord::Migration
  def self.up
    create_table :albums do |t|
      t.string :title
      t.text :description
      t.integer :user_id

      t.timestamps null: false
    end
  end

  def self.down
    drop_table :albums
  end
end
