require File.dirname(__FILE__) + '/../test_helper'
require 'contests_controller'

# Re-raise errors caught by the controller.
class ContestsController; def rescue_action(e) raise e end; end

class ContestsControllerTest < Test::Unit::TestCase
  fixtures :contests, :users, :roles

  def setup
    @controller = ContestsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:contests)
  end

  def test_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end
  
  def test_should_create_contest
    login_as :admin
    assert_difference Contest, :count, 1 do
      post :create, :contest => {:title => 'created from tests', :banner_title => 'created from tests', :banner_subtitle => 'created from tests', :begin => 500.days.ago.to_s, :end => 0.days.ago.to_s }
    end
    assert_redirected_to contest_path(assigns(:contest))
  end

  def test_should_require_title
    login_as :admin
    assert_no_difference Contest, :count do
      post :create, :contest => {:banner_title => 'created from tests', :banner_subtitle => 'created from tests', :begin => 500.days.ago.to_s, :end => 0.days.ago.to_s }
    end
    assert assigns(:contest).errors.on(:title)
  end

  def test_should_show_contest
    login_as :admin
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    login_as :admin
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_contest
    login_as :admin
    put :update, :id => 1, :contest => { }
    assert_redirected_to contest_path(assigns(:contest))
  end
  
  def test_should_fail_to_update_contest
    login_as :admin
    put :update, :id => 1, :contest => {:title => nil }
    assert assigns(:contest).errors.on(:title)
  end
  
  def test_should_destroy_contest
    login_as :admin
    old_count = Contest.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Contest.count
    
    assert_redirected_to contests_path
  end
end
