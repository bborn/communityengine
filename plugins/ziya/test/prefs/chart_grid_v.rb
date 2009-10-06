$:.unshift(File.dirname(__FILE__) + '/..')
require 'test_helper'
require 'test/unit'
require 'ziya'

class ChartGridVTest < Test::Unit::TestCase    
  include TestHelper 
  
  # ---------------------------------------------------------------------------
  # Tests flatten xml generation
  def test_flatten
    xx           = Ziya::Components::ChartGridV.new
    xx.thickness = 1
    xx.color     = "ff00ff"
    xx.alpha     = 10
    xx.type      = "solid"

    xml = Builder::XmlMarkup.new
    xx.flatten( xml )
    result = xml.to_s
    p result
    check_results( result.gsub( /<to_s\/>/, ''), 
                   File.join( File.expand_path( "." ), "/test/xmls/chart_grid_v.xml" ) )
  end

  # ---------------------------------------------------------------------------
  # Tests flatten xml generation
  def test_mismatch
    xx           = Ziya::Components::ChartGridV.new
    xx.thickness = 2
    xx.color     = "ff00ff"
    xx.alpha     = 10
    xx.type      = "solid"
    
    xml = Builder::XmlMarkup.new
    xx.flatten( xml )
    result = xml.to_s
    
    begin
      check_results( result.gsub( /<to_s\/>/, ''), 
                     File.join( File.expand_path( "." ), "/test/xmls/chart_grid_v.xml" ) )
    rescue => boom
      assert_equal "Attribute mismatch for key 'thickness'.\n<\"1\"> expected but was\n<\"2\">.", boom.to_s
      return
    end
    fail "Expecting exception"
  end
end
