require File.dirname(__FILE__) + '/../test_helper'
require 'metro_areas_controller'

# Re-raise errors caught by the controller.
class MetroAreasController; def rescue_action(e) raise e end; end

class MetroAreasControllerTest < Test::Unit::TestCase
  fixtures :metro_areas, :users, :countries, :roles

  def setup
    @controller = MetroAreasController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:metro_areas)
  end

  def test_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end
  
  def test_should_create_metro_area
    login_as :admin
    assert_difference MetroArea, :count, 1 do
      post :create, :metro_area => {:country_id => countries(:germany), :name => "Dusseldorf" } 
    end
    
    assert_redirected_to metro_area_path(assigns(:metro_area))
  end

  def test_should_create_metro_area_without_country
    login_as :admin
    assert_no_difference MetroArea, :count do
      post :create, :metro_area => {:name => "Dusseldorf" } 
      assert assigns(:metro_area).errors.on(:country)
      assert_response :success
    end
  end

  def test_should_show_metro_area
    login_as :admin
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    login_as :admin
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_metro_area
    login_as :admin
    put :update, :id => 1, :metro_area => { }
    assert_redirected_to metro_area_path(assigns(:metro_area))
  end
  
  def test_should_destroy_metro_area
    login_as :admin
    old_count = MetroArea.count
    delete :destroy, :id => 1
    assert_equal old_count-1, MetroArea.count
    
    assert_redirected_to metro_areas_path
  end
end
