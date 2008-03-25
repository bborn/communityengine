require File.dirname(__FILE__) + '/../test_helper'
require 'statistics_controller'

# Re-raise errors caught by the controller.
class StatisticsController; def rescue_action(e) raise e end; end

class StatisticsControllerTest < Test::Unit::TestCase
  fixtures :users
  
  def setup
    @controller = StatisticsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    login_as :admin
    get :index
    assert_response :success
  end

  def test_should_not_get_index
    login_as :quentin
    get :index
    assert_redirected_to login_url
  end
end
