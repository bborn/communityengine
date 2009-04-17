class Category < ActiveRecord::Base
  has_many :posts, :order => "published_at desc"

  def to_param
    id.to_s << "-" << (name ? name.parameterize : '' )
  end
  
  def slug
    name.parameterize.downcase
  end

  def self.get(name)
    self.find_by_name(name.to_s.humanize)
  end
  
  def display_new_post_text
    new_post_text
  end
  
end
