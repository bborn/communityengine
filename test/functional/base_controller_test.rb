require File.dirname(__FILE__) + '/../test_helper'

class BaseControllerTest < ActionController::TestCase
  fixtures :clippings, :users, :photos, :homepage_features, :taggings, :tags, :posts, :categories, :roles

  def setup
    @controller = BaseController.new
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
  
end
