require File.dirname(__FILE__) + '/../test_helper'
#
# Normally we do this, but we ommit it here so Engines can do its code mixing magic
#
# require 'base_controller'
# Re-raise errors caught by the controller.
# class BaseController < ApplicationController; def rescue_action(e) raise e end; end

class BaseControllerTest < Test::Unit::TestCase
  fixtures :clippings, :users, :photos, :homepage_features, :taggings, :tags, :posts, :categories, :roles

  def setup
    @controller = BaseController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    Asset.destroy_all    
  end
    
  def test_should_get_index
    get :site_index
    assert_response :success
    assert assigns(:active_users)
  end
  
  def test_should_get_index_rss
    get :site_index, :format => 'rss'
    assert_generates("/site_index.rss", :controller => "base", :action => "site_index", :format => 'rss')    
    assert_response :success
  end

  def test_should_get_footer_content
    get :footer_content
    assert_response :success
  end
  
  def test_should_get_teaser
    get :teaser
    assert_response :success
  end

  def test_should_get_additional_homepage_data
    assert @controller.get_additional_homepage_data
  end
  
  def test_should_get_about
    get :about
    assert_response :success
    
  end
  
end
