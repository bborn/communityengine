require 'test_helper'

class MetroAreasControllerTest < ActionController::TestCase
  fixtures :metro_areas, :users, :countries, :roles

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

  def test_should_not_create_metro_area_without_country
    login_as :admin
    assert_no_difference MetroArea, :count do
      post :create, :metro_area => {:name => "Dusseldorf" } 
      assert assigns(:metro_area).errors[:country_id]
      assert_response :success
    end
  end

  def test_should_show_metro_area
    login_as :admin
    get :show, :id => metro_areas(:twincities).id
    assert_response :success
  end

  def test_should_get_edit
    login_as :admin
    get :edit, :id => metro_areas(:twincities).id
    assert_response :success
  end
  
  def test_should_update_metro_area
    login_as :admin
    put :update, :id => metro_areas(:twincities).id, :metro_area => { }
    assert_redirected_to metro_area_path(assigns(:metro_area))
  end
  
  def test_should_destroy_metro_area
    login_as :admin
    assert_difference MetroArea, :count, -1 do
      delete :destroy, :id => metro_areas(:twincities).id
    end

    assert_redirected_to metro_areas_path
  end
end
