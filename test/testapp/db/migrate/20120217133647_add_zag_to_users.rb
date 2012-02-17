class AddZagToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :zip, :string
    add_column :users, :birthday, :date
    add_column :users, :gender, :string
  end

  def self.down
    remove_column :users, :zip
    remove_column :users, :birthday
    remove_column :users, :gender
  end
end
