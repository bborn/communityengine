class CategoryImprovements < ActiveRecord::Migration
  def self.up
    add_column :categories, :new_post_text, :string
    add_column :categories, :nav_text, :string
  end

  def self.down
    remove_column :categories, :new_post_text
    remove_column :categories, :nav_text
  end
end
