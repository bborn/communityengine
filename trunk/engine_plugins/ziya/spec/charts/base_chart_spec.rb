$:.unshift(File.dirname(__FILE__) + '/../../lib')
             
puts File.dirname(__FILE__) + '/rspec_helper'  

require 'ziya' 
require File.dirname(__FILE__) + '/rspec_helper.rb'

# TODO Add specs to test validation on add

context "A new base chart" do
  setup do
    @base = Ziya::Charts::Base.new( "my_license", "Test", "test_me" )
  end
  specify "should have a title" do
    @base.title.should_eql "Test"
  end
  specify "should have a license" do
    @base.license.should_eql "my_license"
  end
  specify "should have an id" do
    @base.id.should_eql "test_me"
  end
  specify "should have a default theme" do
    @base.theme.should_eql "./spec/charts/../../lib/ziya/charts/../../../artifacts/themes/default"
  end
end

context "A chart with a category and an series" do
  setup do
    @base = Ziya::Charts::Base.new
    @base.add( :axis_category_text, %w{ 2004 2005 2006 } )
    @base.add( :series, "SerieA", [10,20,30] )      
  end
  specify "should have 4 categories" do
    @base.options[:axis_category_text].size.should_equal 4
  end
  specify "should have 2 options" do
    @base.options.size.should_equal 2
  end  
  specify "should have a series" do
    @base.options[:series_1_SerieA].size.should_equal 4
  end    
  specify "should not have labels" do
    @base.options[:labels_1_SerieA].should_be.nil
  end    
end

context "A chart with a category and a series with labels" do
  setup do
    @base = Ziya::Charts::Base.new
    @base.add( :axis_category_text, %w{ 2004 2005 2006 } )
    @base.add( :series, "SerieA", [10,20,30], %w{ dog cat rat} )    
  end
  specify "should have 3 options" do
    @base.options.size.should_equal 3
  end  
  specify "should have a series" do
    @base.options[:series_1_SerieA].size.should_equal 4
  end    
  specify "should have an array of labels" do
    @base.options[:labels_1_SerieA].should_be_instance_of Array
  end    
  specify "should have 3 labels" do
    @base.options[:labels_1_SerieA].size.should_equal 3
  end      
end

context "A chart with a category, axis values and a series with labels" do
  setup do
    @base = Ziya::Charts::Base.new
    @base.add( :axis_category_text, %w{ 2004 2005 2006 } )
    @base.add( :series, "SerieA", [10,20,30], %w{ dog cat rat} )    
    @base.add( :axis_value_text, %w{ 1 2 3 } )
  end
  specify "should have 4 options" do
    @base.options.size.should_equal 4
  end  
  specify "should have an array of axis values" do
    @base.options[:axis_value_text].should_be_instance_of Array
  end    
  specify "should have 3 axis values" do
    @base.options[:axis_value_text].size.should_equal 3
  end    
end

context "A chart with user data" do
  setup do
    @base = Ziya::Charts::Base.new
    @base.add( :axis_category_text, %w{ 2004 2005 2006 } )
    @base.add( :series, "SerieA", [10,20,30], %w{ dog cat rat} )    
    @base.add( :axis_value_text, %w{ 1 2 3 } )
    @base.add( :user_data, :fred, "fred" )
    @base.add( :user_data, :list, [1,2,3] )
  end
  specify "should have 6 options" do
    @base.options.size.should_equal 6
  end  
  specify "should have user data 'fred'" do
    @base.options[:fred].should_be_instance_of String
    @base.options[:fred].should_be_eql "fred"   
  end    
  specify "should have user data 'list'" do
    @base.options[:list].should_be_instance_of Array
    @base.options[:list].size.should_be_equal 3
  end    
end

context "A chart with theme" do
  setup do
    @base = Ziya::Charts::Base.new
    @base.add( :axis_category_text, %w{ 2004 2005 2006 } )
    @base.add( :series, "SerieA", [10,20,30], %w{ dog cat rat} )    
    @base.add( :axis_value_text, %w{ 1 2 3 } )
    @base.add( :user_data, :fred, "fred" )
    @base.add( :user_data, :list, [1,2,3] )
    @base.add( :theme, "commando" )
  end
  specify "should have 6 options" do
    @base.options.size.should_equal 6
  end  
  specify "should have commando theme" do
    @base.theme.should_be_eql "./spec/charts/../../lib/ziya/charts/../../../artifacts/themes/commando" 
  end    
end

context "A rendered chart" do 
  include RspecHelper
  setup do
    @base = Ziya::Charts::Base.new
    @base.add( :axis_category_text, %w{ 2004 2005 2006 } )
    @base.add( :series, "SerieA", [10,20,30], %w{ dog cat rat} )    
    @base.add( :axis_value_text, %w{ 1 2 3 } )
    @base.add( :user_data, :fred, "fred" )
    @base.add( :user_data, :list, [1,2,3] )
    @base.add( :theme, "commando" )
  end
  specify "should have 6 options" do
    @base.options.size.should_equal 6
  end  
  specify "should render per specification" do     
    check_results( @base.to_s, "./test/xmls/rspec1.xml" ).should_equal true
  end    
end