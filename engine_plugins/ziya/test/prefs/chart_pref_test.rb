$:.unshift(File.dirname(__FILE__) + '/..')
require 'test_helper'
require 'test/unit'
require 'ziya'

class ChartPrefTest < Test::Unit::TestCase    
  include TestHelper 
  
  # ---------------------------------------------------------------------------
  # Tests flatten xml generation
  def test_flatten
    ax                 = Ziya::Components::ChartPref.new
    ax.point_shape     = "circle"
    ax.fill_shape      = true
    ax.reverse         = true
    ax.type            = "body"
    ax.line_thickness  = 10
    ax.bull_color      = "ff0000"
    ax.bear_color      = "00ff00"
    ax.point_size      = 5
    ax.point_shape     = "square"
    ax.trend_thickness = 10
    ax.trend_alpha     = 50
    ax.line_alpha      = 100
    ax.rotation_x      = 90
    ax.rotation_y      = -90
    ax.grid            = "linear"
    
    xml = Builder::XmlMarkup.new
    ax.flatten( xml )
    result = xml.to_s
    check_results( result.gsub( /<to_s\/>/, ''), 
                   File.join( File.expand_path( "." ), "/test/xmls/chart_pref.xml" ) )
  end
  
  # ---------------------------------------------------------------------------
  # Tests flatten xml generation
  def test_mismatch
    ax                 = Ziya::Components::ChartPref.new
    ax.point_shape     = "circle"
    ax.fill_shape      = true
    ax.reverse         = true
    ax.type            = "body"
    ax.line_thickness  = 10
    ax.bull_color      = "ff0000"
    ax.bear_color      = "00ff00"
    ax.point_size      = 5
    ax.point_shape     = "circle"
    ax.trend_thickness = 10
    ax.trend_alpha     = 50
    ax.line_alpha      = 100
    ax.rotation_x      = 90
    ax.rotation_y      = -90
    ax.grid            = "linear"
    
    xml = Builder::XmlMarkup.new
    ax.flatten( xml )
    result = xml.to_s
    
    begin
      check_results( result.gsub( /<to_s\/>/, ''), 
                     File.join( File.expand_path( "." ), "/test/xmls/chart_pref.xml" ) )
    rescue => boom
      assert_equal "Attribute mismatch for key 'point_shape'.\n<\"square\"> expected but was\n<\"circle\">.", boom.to_s
      return
    end
    fail "Expecting exception"
  end  
end
