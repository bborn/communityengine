# This migration comes from community_engine (originally 56)
class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.column :name, :string
    end

    Role.enumeration_model_updates_permitted = true
    Role.create({ :name => 'admin' }, :without_protection => true)    
    Role.create({ :name => 'moderator' }, :without_protection => true)
    Role.create({ :name => 'member' }, :without_protection => true)            
    Role.enumeration_model_updates_permitted = false
    
    add_column :users, :role_id, :integer

    #set all existing users to 'member'
    User.update_all("role_id = #{Role[:member].id}", ["admin = ?", false])
    #set admins to 'admin'
    User.update_all("role_id = #{Role[:admin].id}", ["admin = ?", true])    

    remove_column :users, :admin
  end

  def self.down
    drop_table :roles
    remove_column :users, :role_id
    add_column :users, :admin, :boolean, :default => false
  end
end
