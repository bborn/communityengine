class CreateOfferings < ActiveRecord::Migration
  def self.up
    create_table :offerings do |t|
      t.column :skill_id, :integer
      t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :offerings
  end
end
