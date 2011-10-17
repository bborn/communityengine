Tag.class_eval do
    
  def to_param
    self.name
  end
  
  def related_tags(limit = 10)
    taggable_ids = self.taggings.find(:all, :limit => 10).collect{|t| t.taggable_id }
    return [] if taggable_ids.blank?
  
    Tag.where("tags.id != '#{self.id}'").select("tags.id, tags.name, COUNT('tags'.id) as count").joins(:taggings).where({:taggings => {:taggable_id => taggable_ids}}).group("tags.id, tags.name").order("count DESC").limit(limit)
  end
  
  def self.popular(limit = 20, type = nil)
    Tag.counts(:at_least => 0).limit(limit).order('count DESC')
  end  
  
end
