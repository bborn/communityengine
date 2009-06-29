$:.unshift(File.dirname(__FILE__) + '/..')
require 'test_helper'
require 'test/unit'
require 'ziya'

class AxisCategoryTest < Test::Unit::TestCase    
  include TestHelper 
  
  # ---------------------------------------------------------------------------
  # Tests xml generation for axis_category
  def test_flatten
    ax              = Ziya::Components::AxisCategory.new
    ax.font         = "Arial"
    ax.size         = 10
    ax.bold         = true
    ax.skip         = 1
    ax.color        = "ff00ff"
    ax.alpha        = 50
    ax.orientation  = "horizontal"
    ax.margin       = 1
    ax.steps        = 4
    ax.min          = -40
    ax.max          = 100
    ax.prefix       = "hello"
    ax.suffix       = "mama"
    ax.decimals     = 2
    ax.decimal_char = '.'
    ax.separator    = '_'
    
    xml = Builder::XmlMarkup.new
    ax.flatten(xml)
    check_results(xml.to_s.gsub(/<to_s\/>/, ''), File.join(File.dirname(__FILE__), '../xmls/axis_category.xml'))
  end
  
  # ---------------------------------------------------------------------------
  # Tests xml generation for axis_ticks
  def test_mismatch
    ax              = Ziya::Components::AxisCategory.new
    ax.font         = "Arial"
    ax.size         = 10
    ax.bold         = true
    ax.skip         = 1
    ax.color        = "ff00ff"
    ax.alpha        = 50
    ax.orientation  = "horizontal"
    ax.margin       = 1
    ax.steps        = 4
    ax.min          = -40
    ax.max          = 100
    ax.prefix       = "hello1"
    ax.suffix       = "mama"
    ax.decimals     = 2
    ax.decimal_char = '.'
    ax.separator    = '_'
    
    xml = Builder::XmlMarkup.new
    ax.flatten(xml)
    
    begin
      check_results(xml.to_s.gsub(/<to_s\/>/, ''), File.join(File.dirname(__FILE__), '../xmls/axis_category.xml'))
    rescue => error
      assert_equal "Attribute mismatch for key 'prefix'.\n<\"hello\"> expected but was\n<\"hello1\">.", error.to_s
      return
    end
    fail "Expecting exception"
  end  
end
