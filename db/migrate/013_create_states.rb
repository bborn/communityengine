class CreateStates < ActiveRecord::Migration
  def self.up
    create_table :states do |t|
      t.column :name, :string
    end
    add_column "users", "state_id", :integer
  end

  def self.down
    drop_table :states
    remove_column "users", "state_id"
  end
end
