class PostgresCompatibilityChanges < ActiveRecord::Migration
  def self.up
    #### POSTGRES USERS ONLY #############
    # With Rails 2.1.1 and greater change_column fails on newer (only tested on 8.3) postgres databases 
    # See http://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/1036
    # Till this is fixed, the workaround is to fix those migrations yourself
    # The migration files contain the commented correct column defintion.
    # Uncomment the correct column definition in those migrations and comment the incorrect one if you are using postgres
    # also comment the change_column calls in this file 

    # for postgres databases: 010_create_invitations.rb, comment the next line
    #change_column :invitations, :user_id, :integer
    rename_column :contests, :begin, :begin_date
    rename_column :contests, :end, :end_date
    # for postgres databases: 047_add_polls.rb
    #change_column :votes, :user_id, :integer
    
    # for postgres databases: 059_create_invitations.rb, comment the next line
    change_column :messages, :recipient_deleted, :boolean, :default => false
  end

  def self.down
    #postgres users can't use the "reversion" on the next line, comment it   
    #change_column :invitations, :user_id, :string    
    rename_column :contests, :begin_date, :begin
    rename_column :contests, :end_date, :end
    #postgres users can't use the "reversion" on the next line, comment it
    #change_column :votes, :user_id, :string
    #postgres users can't use the "reversion" on the next line, comment it
    change_column :messages, :recipient_deleted, :boolean, :default => 0
  end
end
