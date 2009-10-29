require File.dirname(__FILE__) + '/../test_helper'

class SitemapControllerTest < ActionController::TestCase

  def test_should_get_sitemap
    get :index
    assert_response :success
  end
end
