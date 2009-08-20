$:.unshift(File.dirname(__FILE__) + '/..')
require 'test_helper'
require 'test/unit'
require 'ziya'

class BaseChartTest < Test::Unit::TestCase    
  include TestHelper 
  
  def setup
    super
    gen_data_sets
  end
  
  # ---------------------------------------------------------------------------
  # Tests xml generation for base charts
  def test_basic
    chart = Ziya::Charts::Base.new( "license" )
    chart.add :axis_category_text, @categories
    chart.add :series, 'Series A', @series_a
    chart.add :series, 'Series B', @series_b
    check_results( chart.to_s, File.join( File.expand_path( "." ), "/test/xmls/basic.xml" ) )
  end

  # ---------------------------------------------------------------------------
  # Test setting series labels and axis values
  def test_advanced
    chart = Ziya::Charts::Base.new( nil, nil, "my_bar_chart" )
    chart.add :axis_category_text, @categories
    chart.add :axis_value_text, %w{ aaa }    
    chart.add :series, 'Series A', @series_a, %w{a}
    chart.add :series, 'Series B', @series_b, %w{aa}
    check_results( chart.to_s, File.join( File.expand_path( "." ), "/test/xmls/advanced.xml" ) )
  end  
   
  # ---------------------------------------------------------------------------
  # Test overriding a given value via inherited properties
  def test_override
    chart = Ziya::Charts::Base.new( "test_license", "TEST", "test" )
    chart.add :axis_category_text, @categories
    chart.add :series, 'Series A', @series_a
    chart.add :series, 'Series B', @series_b
    check_results( chart.to_s, File.join( File.expand_path( "." ), "/test/xmls/override.xml" ) )
  end        
  
  # ---------------------------------------------------------------------------
  # Test overriding a given value via inherited properties
  def test_override
    chart = Ziya::Charts::Base.new( "test_license", "TEST", "test" )
    chart.add :axis_category_text, @categories
    chart.add :series, 'Series A', @series_a
    chart.add :series, 'Series B', @series_b
    check_results( chart.to_s, File.join( File.expand_path( "." ), "/test/xmls/override.xml" ) )
  end        
  
  
  # ---------------------------------------------------------------------------
  # Test data set
  def gen_data_sets    
    now = DateTime.now
    @categories = []
    1.times { |i| @categories << (now-i).strftime( "%m/%d" ) }
    
    @series_a = [ "Series A" ]
    1.times { |i| @series_a << 100 }
    
    @series_b = [ "Series B" ]
    1.times { |i| @series_b << 50 }
  end  
end
