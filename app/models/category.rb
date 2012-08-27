class Category < ActiveRecord::Base
  has_many :posts, :order => "published_at desc"
  validates_presence_of :name
  
  attr_accessible :name, :tips, :new_post_text, :nav_text
  
  has_friendly_id :name, :use_slug => true
      
  def display_new_post_text
    if new_post_text.blank?
      false      
    else
      new_post_text
    end
  end
  
end
