class AddAnonymousCommentingFields < ActiveRecord::Migration
  def self.up
    add_column :comments, :author_name, :string
    add_column :comments, :author_email, :string
    add_column :comments, :author_url, :string
    add_column :comments, :author_ip, :string
  end
  
  def self.down
    remove_column :comments, :author_name
    remove_column :comments, :author_email
    remove_column :comments, :author_url
    remove_column :comments, :author_ip
  end  
end
