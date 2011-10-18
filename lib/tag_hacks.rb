Tag.instance_eval do

  def popular(limit = 20, type = nil)
    tags = Tag.counts(:at_least => 0).limit(limit).order('count DESC')
    tags = tags.where("taggings.taggable_type = ?", type.capitalize) if type
    tags
  end  
  
end

Tag.class_eval do
    
  def to_param
    self.name
  end
  
  def related_tags(limit = 10)
    taggable_ids = self.taggings.find(:all, :limit => 10).collect{|t| t.taggable_id }
    return [] if taggable_ids.blank?
  
    Tag.where("tags.id != '#{self.id}'").select("tags.id, tags.name, COUNT(tags.id) as count").joins(:taggings).where({:taggings => {:taggable_id => taggable_ids}}).group("tags.id, tags.name").order("count DESC").limit(limit)
  end
    
end