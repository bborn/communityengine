class AddPolls < ActiveRecord::Migration
  def self.up
    create_table :polls do |t|
      t.column :question,   :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :post_id, :integer
      t.column :votes_count, :integer, :default => 0
    end
    
    create_table :choices do |t|
      t.column :poll_id, :integer
      t.column :description, :string
      t.column :votes_count, :integer, :default => 0
    end
    
    create_table :votes do |t|
      t.column :user_id, :string
      t.column :poll_id, :integer
      t.column :choice_id, :integer
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :polls
    drop_table :choices    
    drop_table :votes    
  end
end