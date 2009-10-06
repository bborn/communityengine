class CreateActivitiesTable < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.column :user_id, :integer, :limit => 10
      t.column :action, :string, :limit => 50
      t.column :item_id, :integer, :limit => 10
      t.column :item_type, :string
      t.column :created_at, :datetime
    end


  end

  def self.down
    drop_table :activities
  end
end
