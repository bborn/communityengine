class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.column :name, :string
    end
    add_column :metro_areas, :country_id, :integer
  end

  def self.down
    drop_table :countries
    remove_column :metro_areas, :country_id
  end
end
