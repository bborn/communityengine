class NewsToTalk < ActiveRecord::Migration
  def self.up
    # Not in a migration!
    # category = Category.create(:name => "Talk")
  end

  def self.down
    # Category.find_by_name("Talk").destroy
  end
end
