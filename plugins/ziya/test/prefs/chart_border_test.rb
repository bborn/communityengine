$:.unshift(File.dirname(__FILE__) + '/..')
require 'test_helper'
require 'test/unit'
require 'ziya'

class ChartBorderTest < Test::Unit::TestCase    
  include TestHelper 
  
  # ---------------------------------------------------------------------------
  # Tests flatten xml generation
  def test_flatten
    xx                  = Ziya::Components::ChartBorder.new
    xx.top_thickness    = 1
    xx.bottom_thickness = 2
    xx.left_thickness   = 3
    xx.right_thickness  = 4
    xx.color            = 5     
    
    xml = Builder::XmlMarkup.new
    xx.flatten( xml )
    result = xml.to_s
    check_results( result.gsub( /<to_s\/>/, ''), 
                   File.join( File.expand_path( "." ), "/test/xmls/chart_border.xml" ) )
  end

  # ---------------------------------------------------------------------------
  # Tests flatten xml generation
  def test_mismatch
    xx                  = Ziya::Components::ChartBorder.new
    xx.top_thickness    = 1
    xx.bottom_thickness = 2
    xx.left_thickness   = 1
    xx.right_thickness  = 4
    xx.color            = 5     
    
    xml = Builder::XmlMarkup.new
    xx.flatten( xml )
    result = xml.to_s
    
    begin
      check_results( result.gsub( /<to_s\/>/, ''), 
                     File.join( File.expand_path( "." ), "/test/xmls/chart_border.xml" ) )
    rescue => boom
      assert_equal "Attribute mismatch for key 'left_thickness'.\n<\"3\"> expected but was\n<\"1\">.", boom.to_s
      return
    end
    fail "Expecting exception"
  end
end
