require File.dirname(__FILE__) + '/../test_helper'
require 'sitemap_controller'

# Re-raise errors caught by the controller.
class SitemapController; def rescue_action(e) raise e end; end

class SitemapControllerTest < Test::Unit::TestCase
  def setup
    @controller = SitemapController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_should_get_sitemap
    get :index
    assert_response :success
  end
end
