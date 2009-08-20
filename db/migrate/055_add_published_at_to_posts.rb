class AddPublishedAtToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :published_at, :datetime

    # Update all existing published posts
    # Set published_at to created_at date for posts that were already published
    Post.update_all("published_at = created_at", "published_as = 'live'")
  end

  def self.down
    remove_column :posts, :published_at
  end

end
