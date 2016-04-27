class CreateRsvps < ActiveRecord::Migration
  def self.up
    create_table :rsvps do |t|
      t.belongs_to :user, :event
      t.integer :attendees_count
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :rsvps
  end
end
