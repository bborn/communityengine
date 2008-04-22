require File.dirname(__FILE__) + '/../test_helper'
require 'activities_controller'

# Re-raise errors caught by the controller.
class ActivitiesController; def rescue_action(e) raise e end; end

class ActivitiesControllerTest < Test::Unit::TestCase
  fixtures :users, :categories, :posts, :comments

  def setup
    @controller = ActivitiesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_network
    login_as :quentin
    get :network, :id => users(:quentin)
    assert_response :success
  end

end
