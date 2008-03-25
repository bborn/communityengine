class CreateMetroAreas < ActiveRecord::Migration
  def self.up
    create_table :metro_areas do |t|
      t.column :name, :string
      t.column :state_id, :integer
    end
    add_column "users", "metro_area_id", :integer
  end

  def self.down
    drop_table :metro_areas
    remove_column "users", "metro_area_id"
  end
end
