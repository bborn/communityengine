require File.dirname(__FILE__) + '/../test_helper'
require 'offerings_controller'

# Re-raise errors caught by the controller.
class OfferingsController; def rescue_action(e) raise e end; end

class OfferingsControllerTest < Test::Unit::TestCase
  fixtures :offerings, :skills, :users, :roles

  def setup
    @controller = OfferingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_replace_offerings
    login_as :dwr
    assert_difference Offering, :count, 2 do
      post :replace, :id => users(:dwr), :users_skills => [skills(:carpentry).id, skills(:plumbing).id]
    end
  end

#  def test_should_get_index
#    get :index
#    assert_response :success
#    assert assigns(:offerings)
#  end
#
#  def test_should_get_new
#    get :new
#    assert_response :success
#  end
#  
#  def test_should_create_offering
#    old_count = Offering.count
#    post :create, :offering => { }
#    assert_equal old_count+1, Offering.count
#    
#    assert_redirected_to user_offering_path(assigns(:offering))
#  end
#
#  def test_should_show_offering
#    get :show, :id => 1
#    assert_response :success
#  end
#
#  def test_should_get_edit
#    get :edit, :id => 1
#    assert_response :success
#  end
#  
#  def test_should_update_offering
#    put :update, :id => 1, :offering => { }
#    assert_redirected_to user_offering_path(assigns(:offering))
#  end
#  
#  def test_should_destroy_offering
#    old_count = Offering.count
#    delete :destroy, :id => 1
#    assert_equal old_count-1, Offering.count
#    
#    assert_redirected_to user_offerings_path
#  end
end
