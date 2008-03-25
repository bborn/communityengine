$:.unshift(File.dirname(__FILE__) + '/..')
require 'test_helper'
require 'test/unit'
require 'ziya'

class ChartGridHTest < Test::Unit::TestCase    
  include TestHelper 
  
  # ---------------------------------------------------------------------------
  # Tests flatten xml generation
  def test_flatten
    xx           = Ziya::Components::ChartGridH.new
    xx.thickness = 1
    xx.color     = "ff00ff"
    xx.alpha     = 10
    xx.type      = "solid"

    xml = Builder::XmlMarkup.new
    xx.flatten( xml )
    result = xml.to_s
    check_results( result.gsub( /<to_s\/>/, ''), 
                   File.join( File.expand_path( "." ), "/test/xmls/chart_grid_h.xml" ) )
  end

  # ---------------------------------------------------------------------------
  # Tests flatten xml generation
  def test_mismatch
    xx           = Ziya::Components::ChartGridH.new
    xx.thickness = 1
    xx.color     = "0000ff"
    xx.alpha     = 10
    xx.type      = "solid"
    
    xml = Builder::XmlMarkup.new
    xx.flatten( xml )
    result = xml.to_s
    
    begin
      check_results( result.gsub( /<to_s\/>/, ''), 
                     File.join( File.expand_path( "." ), "/test/xmls/chart_grid_h.xml" ) )
    rescue => boom
      assert_equal "Attribute mismatch for key 'color'.\n<\"ff00ff\"> expected but was\n<\"0000ff\">.", boom.to_s
      return
    end
    fail "Expecting exception"
  end
end
