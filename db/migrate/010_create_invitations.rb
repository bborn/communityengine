class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.column "email_addresses", :string
      t.column "message", :string
      t.column "user_id", :string
      t.column "created_at", :datetime
    end
  end

  def self.down
    drop_table :invitations
  end
end
