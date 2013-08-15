class UpgradeToActsAsCommentable4x < ActiveRecord::Migration
  def self.up
    change_table :comments do |t|
      t.string :new_title, :limit => 50, :default => ""
      t.text :new_comment
      t.string :role, :default => "comments"
    end

    Comment.all.map do |comment|
      comment.new_title = comment.title
      comment.new_comment = comment.comment
      comment.save
    end

    change_table :comments do |t|
      t.remove :title
      t.remove :comment
      t.rename :new_title, :title
      t.rename :new_comment, :comment
    end

  end

  def self.down
    change_table :columns do |t|
      t.remove :role
    end
  end
end
