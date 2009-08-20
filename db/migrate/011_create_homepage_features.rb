class CreateHomepageFeatures < ActiveRecord::Migration
  def self.up
    create_table :homepage_features do |t|
      t.column :created_at, :datetime
      t.column :url, :string
      t.column :title, :string
      t.column :description, :text
      t.column :updated_at, :datetime
      t.column :content_type, :string
      t.column :filename, :string
      t.column :parent_id, :integer
      t.column :thumbnail, :string
      t.column :size, :integer
      t.column :width, :integer
      t.column :height, :integer
    end
  end

  def self.down
    drop_table :homepage_features
  end
end
