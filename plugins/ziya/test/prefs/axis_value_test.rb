$:.unshift(File.dirname(__FILE__) + '/..')
require 'test_helper'
require 'test/unit'
require 'ziya'

class AxisValueTest < Test::Unit::TestCase    
  include TestHelper 
  
  # ---------------------------------------------------------------------------
  # Tests flatten xml generation
  def test_flatten
    xx                 = Ziya::Components::AxisValue.new
    xx.min             = -100
    xx.max             =  100    
    xx.prefix          = 'blee'
    xx.steps           = 3
    xx.suffix          = 'duh'
    xx.decimals        = 2
    xx.decimal_char    = ","    
    xx.separator       = "_"
    xx.show_min        = true
    xx.font            = 'Arial'
    xx.bold            = true
    xx.size            = 10
    xx.color           = 'ff00ff'
    xx.background_color= '00ff00'
    xx.alpha           = 10
    xx.orientation     = 'horizontal'
    
    xml = Builder::XmlMarkup.new
    xx.flatten( xml )
    result = xml.to_s
    check_results( result.gsub( /<to_s\/>/, ''), 
                   File.join( File.expand_path( "." ), "/test/xmls/axis_value.xml" ) )
  end

  # ---------------------------------------------------------------------------
  # Tests flattem xml generation
  def test_mismatch
    xx                 = Ziya::Components::AxisValue.new
    xx.min             = -100
    xx.max             =  100    
    xx.prefix          = 'blee'
    xx.steps           = 4
    xx.suffix          = 'duh'
    xx.decimals        = 2
    xx.decimal_char    = ","    
    xx.separator       = "_"
    xx.show_min        = true
    xx.font            = 'Arial'
    xx.bold            = true
    xx.size            = 10
    xx.color           = 'ff00ff'
    xx.background_color= '00ff00'
    xx.alpha           = 10
    xx.orientation     = 'horizontal'
    
    xml = Builder::XmlMarkup.new
    xx.flatten( xml )
    result = xml.to_s
    
    begin
      check_results( result.gsub( /<to_s\/>/, ''), 
                   File.join( File.expand_path( "." ), "/test/xmls/axis_value.xml" ) )
    rescue => boom
      assert_equal "Attribute mismatch for key 'steps'.\n<\"3\"> expected but was\n<\"4\">.", boom.to_s
      return
    end
    fail "Expecting exception"
  end
end
