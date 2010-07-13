require File.dirname(__FILE__) + '/../test_helper'

class CategoriesControllerTest < ActionController::TestCase
  fixtures :categories, :users, :roles

  def test_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:categories)
  end

  def test_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end
  
  def test_should_create_category
    login_as :admin
    assert_difference Category, :count, 1 do
      post :create, :category => { }
    end    
    assert_redirected_to category_path(assigns(:category))
  end

  def test_should_show_category
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    login_as :admin
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_category
    login_as :admin
    put :update, :id => 1, :category => { }
    assert_redirected_to category_path(assigns(:category))
  end
  
  def test_should_destroy_category
    login_as :admin
    assert_difference Category, :count, -1 do
      delete :destroy, :id => 1
    end
    assert_redirected_to categories_path
  end
end
