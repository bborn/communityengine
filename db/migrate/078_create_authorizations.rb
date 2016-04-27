class CreateAuthorizations < ActiveRecord::Migration
  def self.up
    create_table :authorizations do |t|
      t.integer :user_id
      t.string :provider
      t.string :uid
      t.string :name
      t.string :nickname
      t.string :email
      t.string :picture_url
      t.string :access_token
      t.string :access_token_secret
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :authorizations
  end
end