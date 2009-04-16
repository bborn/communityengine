require File.dirname(__FILE__) + '/../test_helper'

class ActivitiesControllerTest < ActionController::TestCase
  fixtures :users, :categories, :posts, :comments, :roles

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
