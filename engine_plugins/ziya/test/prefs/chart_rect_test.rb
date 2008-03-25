$:.unshift(File.dirname(__FILE__) + '/..')
require 'test_helper'
require 'test/unit'
require 'ziya'

class ChartRectTest < Test::Unit::TestCase    
  include TestHelper   
  # ---------------------------------------------------------------------------
  # Tests flatten xml generation
  def test_flatten
    ax                 = Ziya::Components::ChartRect.new
    ax.x               = 10
    ax.y               = 100
    ax.width           = 300
    ax.height          = 200
    ax.positive_color  = "ff0000"
    ax.positive_alpha  = 20
    ax.negative_color  = "00ff00"
    ax.negative_alpha  = 10
    
    xml = Builder::XmlMarkup.new
    ax.flatten( xml )
    result = xml.to_s
    check_results( result.gsub( /<to_s\/>/, ''), 
                   File.join( File.expand_path( "." ), "/test/xmls/chart_rect.xml" ) )
  end
  
  # ---------------------------------------------------------------------------
  # Tests flatten xml generation
  def test_mismatch
    ax                 = Ziya::Components::ChartRect.new
    ax.x               = 10
    ax.y               = 100
    ax.width           = 301
    ax.height          = 200
    ax.positive_color  = "ff0000"
    ax.positive_alpha  = 20
    ax.negative_color  = "00ff00"
    ax.negative_alpha  = 10
    
    xml = Builder::XmlMarkup.new
    ax.flatten( xml )
    result = xml.to_s
    
    begin
      check_results( result.gsub( /<to_s\/>/, ''), 
                     File.join( File.expand_path( "." ), "/test/xmls/chart_rect.xml" ) )
    rescue => boom
      assert_equal "Attribute mismatch for key 'width'.\n<\"300\"> expected but was\n<\"301\">.", boom.to_s
      return
    end
    fail "Expecting exception"
  end  
end
