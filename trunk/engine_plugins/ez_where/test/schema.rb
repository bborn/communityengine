ActiveRecord::Schema.define(:version => 1) do
  
  create_table :articles do |t|
    t.column :title, :string
    t.column :body, :text
    t.column :author_id, :integer
  end

  create_table :authors do |t|
    t.column :name, :string
  end

  create_table :comments do |t|
    t.column :body, :text
    t.column :article_id, :integer
    t.column :author_id, :integer
  end

end