require File.dirname(__FILE__) + '/../test_helper'
require 'theme_controller'

# Re-raise errors caught by the controller.
class ThemeController; def rescue_action(e) raise e end; end

class ThemeControllerTest < Test::Unit::TestCase
  def setup
    @controller = ThemeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_malicious_path
    AppConfig.theme = 'test'
    get :stylesheets, :filename => "../../../config/database.yml"
    assert_response 404
  end

end
