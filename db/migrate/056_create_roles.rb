class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.column :name, :string
    end

    Role.enumeration_model_updates_permitted = true
    ['admin', 'moderator', 'member'].each do | role_name |
      r = Role.new
      r.name = role_name
      r.save!
    end
    Role.enumeration_model_updates_permitted = false

    add_column :users, :role_id, :integer

    #set all existing users to 'member'
    User.where("admin = ?", false).update_all("role_id = #{Role[:member].id}")
    #set admins to 'admin'
    User.where("admin = ?", true).update_all("role_id = #{Role[:admin].id}")

    remove_column :users, :admin
  end

  def self.down
    drop_table :roles
    remove_column :users, :role_id
    add_column :users, :admin, :boolean, :default => false
  end
end
