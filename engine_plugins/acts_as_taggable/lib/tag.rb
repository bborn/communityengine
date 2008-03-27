class Tag < ActiveRecord::Base
  has_many :taggings

  def self.parse(list)
    tag_names = []

    # first, pull out the quoted tags
    list.gsub!(/\"(.*?)\"\s*/ ) { tag_names << $1; "" }

    # then, replace all commas with a space
    list.gsub!(/,/, " ")

    # then, get whatever's left
    tag_names.concat list.split(/\s/)

    # strip whitespace from the names
    tag_names = tag_names.map { |t| t.strip }

    # delete any blank tag names
    tag_names = tag_names.delete_if { |t| t.empty? }
    
    # replace slashes, periods, and semi-colons with dashes
    tag_names = tag_names.map {|t| t.gsub(/[\/]/, '-')}
    tag_names = tag_names.map {|t| t.gsub(/[\.]/, '-')}
    tag_names = tag_names.map {|t| t.gsub(/[\;]/, '-')}    
        
    return tag_names
  end

  def self.find_list(tag_list)
    find(:all, :conditions => [ 'LOWER(name) LIKE ?', '%' + tag_list + '%' ])
  end

  def related_tags(options = {})
    taggable_ids = self.taggings.find(:all, :limit => 10).collect{|t| t.taggable_id }
    return [] if taggable_ids.empty?
    
    sql = "SELECT tags.id, tags.name, count(*) AS count FROM tags  
      LEFT OUTER JOIN taggings 
      ON taggings.tag_id = tags.id 
      WHERE (taggings.taggable_id IN (#{taggable_ids.join(',')})) 
      AND tags.id != '#{self.id}'
      GROUP BY tags.id 
      ORDER BY count DESC  
      LIMIT 10"
    tags = Tag.find_by_sql(sql)
  end

  def tagged
    @tagged ||= taggings.collect { |tagging| tagging.taggable }
  end
  
  def on(taggable)
    taggings.create :taggable => taggable
  end
  
  def ==(comparison_object)
    super || name == comparison_object.to_s
  end
  
  def to_s
    name
  end
end