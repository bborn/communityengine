class CreateUsers < ActiveRecord::Migration
  class User < ActiveRecord::Base  
  end
  def self.up
    create_table "users", :force => true do |t|
      t.column :login,                     :string
      t.column :email,                     :string
      t.column :description,               :text
      t.column :avatar_id,                 :integer
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :stylesheet,                :text 
      t.column :view_count,                :integer, :default => 0
      t.column :admin,                     :boolean, :default => false
      t.column :vendor,                    :boolean, :default => false
    end
  end

  def self.down
    drop_table "users"
  end
end
