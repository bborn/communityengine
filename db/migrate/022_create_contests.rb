class CreateContests < ActiveRecord::Migration
  def self.up
    create_table :contests do |t|
      t.column :title, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :begin, :datetime
      t.column :end, :datetime
      t.column :raw_post, :text
      t.column :post, :text
    end
    
    add_column :posts, :contest_id, :integer
  end

  def self.down
    drop_table :contests
    remove_column :posts, :contest_id
  end
end
