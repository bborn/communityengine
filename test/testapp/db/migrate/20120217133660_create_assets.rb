class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.column :filename, :string
      t.column :width, :integer
      t.column :height, :integer
      t.column :content_type, :string
      t.column :size, :integer
      t.column :attachable_type, :string
      t.column :attachable_id, :integer
      t.column :updated_at, :datetime
      t.column :created_at, :datetime
      t.column :thumbnail, :string
      t.column :parent_id, :integer
    end
  end

  def self.down
    drop_table :assets
  end
end
