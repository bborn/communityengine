$:.unshift(File.dirname(__FILE__) + '/..')
require 'test_helper'
require 'test/unit'
require 'ziya'

class ChartTransitionTest < Test::Unit::TestCase    
  include TestHelper   
  # ---------------------------------------------------------------------------
  # Tests flatten xml generation
  def test_flatten
    ax                 = Ziya::Components::ChartTransition.new
    ax.type            = "drop"
    ax.delay           = 1.0
    ax.duration        = 0.5
    ax.order           = "category"
    
    xml = Builder::XmlMarkup.new
    ax.flatten( xml )
    result = xml.to_s
    check_results( result.gsub( /<to_s\/>/, ''), 
                   File.join( File.expand_path( "." ), "/test/xmls/chart_transition.xml" ) )
  end
  
  # ---------------------------------------------------------------------------
  # Tests flatten xml generation
  def test_mismatch
    ax                 = Ziya::Components::ChartTransition.new
    ax.type            = "drop"
    ax.delay           = 1.5
    ax.duration        = 0.5
    ax.order           = "category"
    
    xml = Builder::XmlMarkup.new
    ax.flatten( xml )
    result = xml.to_s
    
    begin
      check_results( result.gsub( /<to_s\/>/, ''), 
                     File.join( File.expand_path( "." ), "/test/xmls/chart_transition.xml" ) )
    rescue => boom
      assert_equal "Attribute mismatch for key 'delay'.\n<\"1.0\"> expected but was\n<\"1.5\">.", boom.to_s
      return
    end
    fail "Expecting exception"
  end  
end
    