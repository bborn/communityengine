class UpgradeToFriendlyId5x < ActiveRecord::Migration
  
  def self.up
    add_column :categories, :slug, :string
    add_index :categories, :slug, :unique => true

    drop_table :slugs
  end  
  
  def self.down
    remove_column :categories, :slug

    create_table :slugs do |t|
      t.string :name
      t.integer :sluggable_id
      t.integer :sequence, :null => false, :default => 1
      t.string :sluggable_type, :limit => 40
      t.string :scope
      t.datetime :created_at
    end
    add_index :slugs, :sluggable_id
    add_index :slugs, [:name, :sluggable_type, :sequence, :scope], :name => "index_slugs_on_n_s_s_and_s", :unique => true
    
  end
end