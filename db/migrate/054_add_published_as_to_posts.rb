class AddPublishedAsToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :published_as, :string, :limit => 16, :default => 'draft'

    #update all existing posts
    Post.update_all("published_as = 'live'")
  end

  def self.down
    remove_column :posts, :published_as
  end

end
