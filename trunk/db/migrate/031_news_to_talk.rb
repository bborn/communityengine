class NewsToTalk < ActiveRecord::Migration
  # was to remove News, but now, just adding talk, not removing news
  def self.up
    category = Category.create(:name => "Talk")
  end

  def self.down
    Category.find_by_name("Talk").destroy
  end
end
