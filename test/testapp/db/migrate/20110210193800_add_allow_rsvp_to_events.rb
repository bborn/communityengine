class AddAllowRsvpToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :allow_rsvp, :boolean, :default => true
  end
  
  def self.down
    remove_column :events, :allow_rsvp
  end
end
