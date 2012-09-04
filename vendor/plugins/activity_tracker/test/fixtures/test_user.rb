class TestUser < ActiveRecord::Base
  has_many :test_posts
  tracks_unlinked_activities [:logged_in]
end
