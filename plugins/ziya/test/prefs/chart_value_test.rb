$:.unshift(File.dirname(__FILE__) + '/..')
require 'test_helper'
require 'test/unit'
require 'ziya'

class ChartTransitionTest < Test::Unit::TestCase    
  include TestHelper   
  # ---------------------------------------------------------------------------
  # Tests flatten xml generation
  def test_flatten
    ax                 = Ziya::Components::ChartValue.new
    ax.prefix          = "blee"
    ax.suffix          = "doh"
    ax.decimals        = 2
    ax.decimal_char    = "."
    ax.separator       = "_"
    ax.position        = 2
    ax.hide_zero       = true
    ax.as_percentage   = true
    ax.font            = "Arial"
    ax.bold            = true
    ax.size            = 10
    ax.color           = "ff00ff"
    ax.background_color= "000000"
    ax.alpha           = 10
    
    xml = Builder::XmlMarkup.new
    ax.flatten( xml )
    result = xml.to_s
    check_results( result.gsub( /<to_s\/>/, ''), 
                   File.join( File.expand_path( "." ), "/test/xmls/chart_value.xml" ) )
  end
  
  # ---------------------------------------------------------------------------
  # Tests flatten xml generation
  def test_mismatch
    ax                 = Ziya::Components::ChartValue.new
    ax.prefix          = "blee"
    ax.suffix          = "doll"
    ax.decimals        = 2
    ax.decimal_char    = "."
    ax.separator       = "_"
    ax.position        = 2
    ax.hide_zero       = true
    ax.as_percentage   = true
    ax.font            = "Arial"
    ax.bold            = true
    ax.size            = 10
    ax.color           = "ff00ff"
    ax.background_color= "000000"
    ax.alpha           = 10
    
    xml = Builder::XmlMarkup.new
    ax.flatten( xml )
    result = xml.to_s
    
    begin
      check_results( result.gsub( /<to_s\/>/, ''), 
                     File.join( File.expand_path( "." ), "/test/xmls/chart_value.xml" ) )
    rescue => boom
      assert_equal "Attribute mismatch for key 'suffix'.\n<\"doh\"> expected but was\n<\"doll\">.", boom.to_s
      return
    end
    fail "Expecting exception"
  end  
end
    