require 'test_helper'

class AdminPostControllerTest < ActionController::TestCase
  fixtures :all

  setup do
    @controller = ::Admin::PostsController.new
  end

  test 'should get index' do
    login_as :admin
    get :index
    assert_response :success
  end

end
