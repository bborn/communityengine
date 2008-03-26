require File.dirname(__FILE__) + '/../test_helper'
require 'application'

# Re-raise errors caught by the controller.
class ApplicationController; def rescue_action(e) raise e end; end

class ApplicationControllerTest < Test::Unit::TestCase
  fixtures :clippings, :users, :photos, :homepage_features, :taggings, :tags, :posts, :categories

  def setup
    @controller = ApplicationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
  end
  
  def test_should_get_index
    get :site_index
    assert_response :success
    assert assigns(:active_users)
  end
  
  def test_should_get_index_rss
    get :site_index, :format => 'rss'
    assert_generates("/site_index.rss", :controller => "application", :action => "site_index", :format => 'rss')    
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
  
end
