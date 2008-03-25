ActiveRecord::Schema.define(:version => 0) do

  create_table :activities, :force => true do |t|
    t.column :user_id, :integer, :limit => 10
    t.column :action, :string, :limit => 50
    t.column :item_id, :integer, :limit => 10
    t.column :item_type, :string
    t.column :created_at, :datetime
  end
  
  create_table :test_users, :force => true do |t|
    t.column :login, :string
  end

  create_table :test_posts, :force => true do |t|
    t.column :title, :string
    t.column :test_user_id, :integer
  end


end