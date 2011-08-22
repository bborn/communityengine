require 'test_helper'

class ThemeControllerTest < ActionController::TestCase

  def test_malicious_path
    configatron.theme = 'test'
    get :stylesheets, :filename => "../../../config/database.yml"
    assert_response 404
  end

end
