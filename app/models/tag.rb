require_dependency File.dirname(__FILE__) + '/../../engine_plugins/acts_as_taggable_on_steroids/lib/tag.rb'

class Tag < ActiveRecord::Base
  
  def related_tags
    taggable_ids = self.taggings.find(:all, :limit => 10).collect{|t| t.taggable_id }
    return [] if taggable_ids.blank?

    sql = "SELECT tags.id, tags.name, count(*) AS count FROM tags
      LEFT OUTER JOIN taggings
      ON taggings.tag_id = tags.id
      WHERE (taggings.taggable_id IN (#{taggable_ids.join(',')}))
      AND tags.id != '#{self.id}'
      GROUP BY tags.id
      ORDER BY count DESC
      LIMIT 10"

    Tag.find_by_sql(sql)
  end
  
  def self.popular(limit = nil, order = ' tags.name ASC', type = nil)
    sql = "SELECT tags.id, tags.name, count(*) AS count 
      FROM taggings, tags 
      WHERE tags.id = taggings.tag_id "
    sql += " AND taggings.taggable_type = '#{type}'" unless type.nil?      
    sql += " GROUP BY tag_id"
    sql += " ORDER BY #{order}"
    sql += " LIMIT #{limit}" if limit
    Tag.find_by_sql(sql)
  end  
  
end
