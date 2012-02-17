require_dependency ActsAsTaggableOn::Engine.config.root.join('app', 'models', 'acts_as_taggable_on', 'tag.rb').to_s

class ActsAsTaggableOn::Tag < ActiveRecord::Base
  
  class << self
    def popular(limit = 20, type = nil)
      tags = ActsAsTaggableOn::Tag.counts(:at_least => 0).limit(limit).order('count DESC')
      tags = tags.where("taggings.taggable_type = ?", type.capitalize) if type
      tags
    end  
  
    def default_per_page
      25
    end    
    
    # Calculate the tag counts for all tags.
    # 
    # - +:start_at+ - restrict the tags to those created after a certain time
    # - +:end_at+   - restrict the tags to those created before a certain time
    # - +:at_least+ - exclude tags with a frequency less than the given value
    # - +:at_most+  - exclude tags with a frequency greater than the given value
    # 
    # Deprecated:
    # 
    # - +:conditions+
    # - +:limit+
    # - +:order+
    # 
    def counts(options = {})
      options.assert_valid_keys :start_at, :end_at, :at_least, :at_most, :conditions, :limit, :order, :joins
      
      tags = joins(:taggings)
      tags = tags.having(['count >= ?', options[:at_least]]) if options[:at_least]
      tags = tags.having(['count <= ?', options[:at_most]])  if options[:at_most]
      tags = tags.where("#{ActsAsTaggableOn::Tagging.quoted_table_name}.created_at >= ?", options[:start_at]) if options[:start_at]
      tags = tags.where("#{ActsAsTaggableOn::Tagging.quoted_table_name}.created_at <= ?", options[:end_at])   if options[:end_at]
      
      # TODO: deprecation warning
      tags = tags.where(options[:conditions]) if options[:conditions]
      tags = tags.limit(options[:limit])      if options[:limit]
      tags = tags.order(options[:order])      if options[:order]
      
      if joins = options.delete(:joins)
        tags = tags.joins(joins)
      end
      
      tags.select("#{quoted_table_name}.id, #{quoted_table_name}.name, COUNT(#{quoted_table_name}.id) AS count").group("#{quoted_table_name}.id, #{quoted_table_name}.name")
    end    
    
    
  end
      
  def to_param
    URI.escape(URI.escape(self.name), /[\/.?#]/)
  end
  
  def related_tags(limit = 10)
    taggables = self.taggings.limit(10).all.collect{|t| t.taggable }
    tagging_ids = taggables.map{|t| t.taggings.limit(10).map(&:id) }.flatten.uniq    
    return [] if tagging_ids.blank?
  
    ActsAsTaggableOn::Tag.where("tags.id != '#{self.id}'").
      select("tags.id, tags.name, COUNT(tags.id) as count").
      joins(:taggings).
      where({:taggings => {:id => tagging_ids }}).
      group("tags.id, tags.name").
      order("count DESC").
      limit(limit)
  end
      
end

