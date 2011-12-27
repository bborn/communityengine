require_dependency ActsAsTaggable::Engine.config.root.join('app', 'models', 'tag.rb').to_s

class Tag < ActiveRecord::Base
  
  class << self
    def popular(limit = 20, type = nil)
      tags = Tag.counts(:at_least => 0).limit(limit).order('count DESC')
      tags = tags.where("taggings.taggable_type = ?", type.capitalize) if type
      tags
    end  
  
    def default_per_page
      25
    end    
  end
      
  def to_param
    URI.escape(URI.escape(self.name), /[\/.?#]/)
  end
  
  def related_tags(limit = 10)
    taggables = self.taggings.limit(10).all.collect{|t| t.taggable }
    tagging_ids = taggables.map{|t| t.taggings.limit(10).map(&:id) }.flatten.uniq    
    return [] if tagging_ids.blank?
  
    Tag.where("tags.id != '#{self.id}'").
      select("tags.id, tags.name, COUNT(tags.id) as count").
      joins(:taggings).
      where({:taggings => {:id => tagging_ids }}).
      group("tags.id, tags.name").
      order("count DESC").
      limit(limit)
  end
      
end

