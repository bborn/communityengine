class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.column "email_addresses", :string
      t.column "message", :string
      
      #t.column "user_id", :string
      # workaround for postgres users until rails bug 1036 is fixed
      # uncomment the line below and comment the line above, see also 061_postgres_compatibility_changes.rb
      t.column "user_id", :integer
      
      t.column "created_at", :datetime
    end
  end

  def self.down
    drop_table :invitations
  end
end
