$:.unshift(File.dirname(__FILE__) + '/..')
require 'test_helper'
require 'test/unit'
require 'ziya'

class AxisTicksTest < Test::Unit::TestCase    
  include TestHelper 
  
  # ---------------------------------------------------------------------------
  # Tests xml generation for axis_ticks
  def test_flatten
    xx                 = Ziya::Components::AxisTicks.new
    xx.value_ticks     = true
    xx.value_ticks     = true    
    xx.category_ticks  = true
    xx.major_thickness = 1
    xx.major_color     = "00ff00"
    xx.minor_thickness = 2
    xx.minor_color     = "ff00aa"    
    xx.minor_count     = 1
    
    xml = Builder::XmlMarkup.new
    xx.flatten( xml )
    result = xml.to_s
    check_results( result.gsub( /<to_s\/>/, ''), 
                   File.join( File.expand_path( "." ), "/test/xmls/axis_ticks.xml" ) )
  end

  # ---------------------------------------------------------------------------
  # Tests xml generation for axis_ticks
  def test_mismatch
    xx                 = Ziya::Components::AxisTicks.new
    xx.value_ticks     = true
    xx.value_ticks     = true    
    xx.category_ticks  = true
    xx.major_thickness = 1
    xx.major_color     = "00ff00"
    xx.minor_thickness = 3
    xx.minor_color     = "ff00aa"    
    xx.minor_count     = 1
    
    xml = Builder::XmlMarkup.new
    xx.flatten( xml )
    result = xml.to_s
    
    begin
      check_results( result.gsub( /<to_s\/>/, ''), 
                     File.join( File.expand_path( "." ), "/test/xmls/axis_ticks.xml" ) )
    rescue => boom
      assert_equal "Attribute mismatch for key 'minor_thickness'.\n<\"2\"> expected but was\n<\"3\">.", boom.to_s
      return
    end
    fail "Expecting exception"
  end
end
