require 'test_helper'

class FavoritesControllerTest < ActionController::TestCase
  fixtures :clippings, :users, :roles

  def setup
    Favorite.destroy_all
  end
  
  def test_should_create_favorite_as_logged_in_user
    login_as :quentin
    assert_difference Favorite, :count, 1 do
      post :create, :favoritable_type => 'clipping', :favoritable_id => clippings(:google).id, :format => 'js'
    end
    assert_response :success
  end
  
  def test_should_create_favorite_anonymously
    assert_difference Favorite, :count, 1 do
      post :create, :favoritable_type => 'clipping', :favoritable_id => clippings(:google).id, :format => 'js'
    end
    assert_response :success
  end

  def test_should_receive_error_when_double_favoriting_as_logged_in_user
    login_as :quentin
    post :create, :favoritable_type => 'clipping', :favoritable_id => clippings(:google).id, :format => 'js'
    post :create, :favoritable_type => 'clipping', :favoritable_id => clippings(:google).id, :format => 'js'
    assert !assigns(:favorite).errors.empty?
  end
  
  def test_should_destroy_favorite
    login_as :quentin    
    post :create, :favoritable_type => 'clipping', :favoritable_id => clippings(:google).id, :format => 'js'    
    
    favorite = users(:quentin).favorites.last

    assert_difference Favorite, :count, -1 do
      delete :destroy, :favoritable_type => 'clipping', :favoritable_id => clippings(:google).id, :id => favorite.id, :format => 'js'    
      assert_response :success
    end
  end
  
  def test_should_get_index
    login_as :quentin
    post :create, :favoritable_type => 'clipping', :favoritable_id => clippings(:google).id, :format => 'js'    
    
    login_as :quentin
    get :index, :user_id => users(:quentin).id
    assert_response :success
  end

end
