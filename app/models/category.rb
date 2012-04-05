class Category < ActiveRecord::Base
  has_many :posts, :order => "published_at desc"
  validates_presence_of :name
  
  has_friendly_id :name, :use_slug => true
      
  def display_new_post_text
    new_post_text
  end
  
end
