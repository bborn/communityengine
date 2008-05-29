class Category < ActiveRecord::Base
  has_many :posts, :order => "published_at desc"

  def to_param
    id.to_s << "-" << (name ? name.gsub(/[^a-z1-9]+/i, '-') : '' )
  end
  
  def slug
    name.gsub(/[^a-z1-9]+/i, '-').downcase
  end
  
  def self.all_names
    find(:all).collect{|c| c.name }
  end

  def self.get(name)
    case name
      when :questions
        cat = 'Questions'
      when :how_to
        cat = 'How To'        
      when :inspiration
        cat = 'Inspiration'  
      when :talk
        cat = 'Talk'  
      when :news
        cat = 'News'  
    end
    self.find_by_name(cat)
  end

  def self.get_recent_count(type)
    get(type).posts.find(:all, :conditions => "published_at > '#{7.days.ago.to_s :db}'").size rescue 0
  end
  
  def display_new_post_text
    new_post_text || "Write a '#{self.name}' post"
  end
  
end
