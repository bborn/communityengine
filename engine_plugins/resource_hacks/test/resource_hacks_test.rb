require File.dirname(__FILE__) + '/test_helper'

class EntriesController < ActionController::Base; end
class ResourceHacksTest < Test::Unit::TestCase
  
  def test_with_member_path
    with_restful_routing :entries, :member_path => '/entries/:year/:month/:day/:permalink' do
      assert_recognizes(
        {:controller => "entries", :action => "index"},
        {:path => "/entries", :method => :get}
      )
      assert_recognizes(
        {:controller => "entries", :action => "new"},
        {:path => "/entries/new", :method => :get}
      )
      assert_recognizes(
        {:controller => "entries", :action => "create"},
        {:path => "/entries", :method => :post}
      )
      assert_recognizes(
        {:controller => "entries", :action => "show",
         :year => "2006", :month => "5", :day => "10",
         :permalink  => "meep"},
        {:path => "/entries/2006/5/10/meep", :method => :get})
      assert_recognizes(
        {:controller => "entries", :action => "edit",
         :year => "2006", :month => "5", :day => "10",
         :permalink  => "meep"},
        {:path => "/entries/2006/5/10/meep;edit", :method => :get})
      assert_recognizes(
        {:controller => "entries", :action => "update",
         :year => "2006", :month => "5", :day => "10",
         :permalink  => "meep"},
        {:path => "/entries/2006/5/10/meep", :method => :put})
      assert_recognizes(
        {:controller => "entries", :action => "destroy",
         :year => "2006", :month => "5", :day => "10",
         :permalink  => "meep"},
        {:path => "/entries/2006/5/10/meep", :method => :delete})
    end
  end
  
  protected
    def with_restful_routing(*resources)
      with_routing do |set|
        set.draw { |map| map.resources(*resources) }
        yield
      end
    end
end
