$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rexml/document'

# -----------------------------------------------------------------------------
# Assist with comparing swf charts xml files
# -----------------------------------------------------------------------------
module TestHelper  
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
      assert_equal map1.size, map2.size, "Maps are not the same size."
    end

    map1.each_pair do |k,v|
      assert_not_nil map2[k], "Unable to find key '#{k}'"
      v1 = map2[k]
      assert_not_nil v1, "Unable to find value for key '#{k}'"
      if ( v.size != v1.size )
        diff = v.keys - v1.keys
        p ">>> Diff #{diff.join(',')}"
        p ">>> #{v.keys.sort { |a,b| a.to_s <=> b.to_s }.join(',')}"
        p ">>> #{v1.keys.sort { |a,b| a.to_s <=> b.to_s }.join(',')}"        
        assert_equal v.size, v1.size, "Attribute for #{k} maps are not the same size"
      end
      v.each do |k,v|
        assert_not_nil v1[k], "Unable to find attribute for key '#{k}'"
        assert_equal v, v1[k], "Attribute mismatch for key '#{k}'"
      end       
    end
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