class AddCategoryNames < ActiveRecord::Migration
  def self.up
    Category.find_or_create_by_name("How To")
    Category.find_or_create_by_name("Inspiration")
    Category.find_or_create_by_name("News")
    Category.find_or_create_by_name("Questions")
  end

  def self.down
  end
end
