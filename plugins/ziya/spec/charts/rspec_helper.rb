$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rexml/document'

# -----------------------------------------------------------------------------
# Assist with comparing swf charts xml files
# -----------------------------------------------------------------------------
module RspecHelper
    
  # ---------------------------------------------------------------------------
  # Check whether the xml generated for a chart and the validation file contain
  # the same data
  def check_results(xml, file_name)
    expected, actual = {}, {}
    traverse(REXML::Document.new(File.new(file_name)), expected)
    traverse(REXML::Document.new(xml.gsub(/<to_s\/>/, "")), actual)
    assert_hash_equals(expected, actual)
  end

  # ---------------------------------------------------------------------------
  # Dumps hash to console
  def dump_hash( map )
    keys = map.keys.sort
    keys.each do |k|
      puts k
      map[k].each do |attr_k, attr_v|
        puts "  #{attr_k} -> #{attr_v}"
      end
    end
  end
    
  # ---------------------------------------------------------------------------
  # Check hash map equality.
  def assert_hash_equals(map1, map2)
    if (map1.size != map2.size)
      diff = map1.keys - map2.keys
      p ">>> Diff #{diff.join(',')}"
      p ">>> #{map1.keys.sort { |a,b| a.to_s <=> b.to_s }.join(',')}"
      p ">>> #{map2.keys.sort { |a,b| a.to_s <=> b.to_s }.join(',')}"
      raise "Maps are not the same size." unless map1.size == map2.size 
    end

    map1.each_pair do |k,v|
      "Unable to find key '#{k}'" unless map2[k].nil? 
      v1 = map2[k]
      "Unable to find value for key '#{k}'" unless v1.nil? 
      if ( v.size != v1.size )
        diff = v.keys - v1.keys
        p ">>> Diff #{diff.join(',')}"
        p ">>> #{v.keys.sort { |a,b| a.to_s <=> b.to_s }.join(',')}"
        p ">>> #{v1.keys.sort { |a,b| a.to_s <=> b.to_s }.join(',')}"        
        "Attribute for #{k} maps are not the same size" unless v.size == v1.size 
      end
      v.each do |k,v|
        "Unable to find attribute for key '#{k}'" unless v1[k].nil?
        "Attribute mismatch for key '#{k}'" unless v == v1[k]
      end       
    end      
    true
  end
  
  # ---------------------------------------------------------------------------
  # Traverse dom and store state in map
  def traverse( e, map1 )
    e.each do |element|
      unless element.instance_of? REXML::Text
        map1[element.name] = element.attributes
        traverse( element, map1 )
      end
    end
  end
end