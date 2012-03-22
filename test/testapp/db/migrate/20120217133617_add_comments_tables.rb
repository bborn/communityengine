class AddCommentsTables < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.column :title, :string
      t.column :comment, :string
      t.references :commentable, :polymorphic => true
      t.references :user
      t.references :recipient
      t.timestamps      
    end

    add_index :comments, ["user_id"], :name => "fk_comments_user"
  end

  def self.down
    drop_table :comments
  end
end
