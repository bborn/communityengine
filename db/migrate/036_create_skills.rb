class CreateSkills < ActiveRecord::Migration
  def self.up
    create_table :skills do |t|
      t.column :name, :string
    end
  end

  def self.down
    drop_table :skills
  end
end
