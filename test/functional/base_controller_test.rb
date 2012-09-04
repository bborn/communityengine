require 'test_helper'

class BaseControllerTest < ActionController::TestCase
  fixtures :clippings, :users, :photos, :homepage_features, :taggings, :tags, :posts, :categories, :roles

  def setup
    Asset.destroy_all    
  end
    
  def test_should_get_index
    get :site_index
    assert_response :success
    assert assigns(:active_users)
  end
  
  def test_should_get_index_rss
    get :site_index, :format => 'rss'
    assert_recognizes({:controller => 'base', :action => 'site_index', :format => 'rss'}, '/site_index.rss')
    assert_response :success
  end

  def test_should_get_footer_content
    get :footer_content
    assert_response :success
  end
  
end
