class PostgresCompatibilityChanges < ActiveRecord::Migration
  def self.up
    change_column :invitations, :user_id, :integer
    rename_column :contests, :begin, :begin_date
    rename_column :contests, :end, :end_date
    change_column :votes, :user_id, :integer
    change_column :messages, :recipient_deleted, :boolean, :default => false
  end

  def self.down
    change_column :invitations, :user_id, :string    
    rename_column :contests, :begin_date, :begin
    rename_column :contests, :end_date, :end
    change_column :votes, :user_id, :string        
    change_column :messages, :recipient_deleted, :boolean, :default => 0    
  end
end
