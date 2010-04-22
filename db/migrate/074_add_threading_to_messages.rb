class AddThreadingToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :parent_id, :integer

    create_table :message_threads do |t|
      t.integer :sender_id
      t.integer :recipient_id
      t.integer :message_id
      t.integer :parent_message_id
      t.timestamps
    end
  end
  
  def self.down
    remove_column :messages, :parent_id
    drop_table :message_threads
  end
end
