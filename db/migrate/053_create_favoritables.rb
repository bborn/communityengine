class CreateFavoritables < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|
      t.column :updated_at, :datetime
      t.column :created_at, :datetime
      t.column :favoritable_type, :string
      t.column :favoritable_id, :integer
      t.column :user_id, :integer
      t.column :ip_address, :string, :default => ''
    end

    add_column :clippings,  :favorited_count, :integer, :default => 0
    add_column :posts,      :favorited_count, :integer, :default => 0    

    add_index :favorites, [:user_id], :name => "fk_favorites_user"
  end

  def self.down
    drop_table :favorites
    remove_column :clippings, :favorited_count
  end
end