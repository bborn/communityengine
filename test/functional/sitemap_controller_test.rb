require File.dirname(__FILE__) + '/../test_helper'

class SitemapControllerTest < ActionController::TestCase
  def setup
    @controller = SitemapController.new
  end

  # Replace this with your real tests.
  def test_should_get_sitemap
    get :index
    assert_response :success
  end
end
