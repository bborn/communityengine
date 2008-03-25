class CreateEventsTable < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.column :name, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :user_id, :integer
      t.column :start_time, :datetime
      t.column :end_time, :datetime
      t.column :description, :text
      t.column :metro_area_id, :integer
      t.column :location, :string
    end
  end

  def self.down
    drop_table :events
  end
end
