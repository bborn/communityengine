require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
  fixtures :categories, :users, :roles


  def test_should_show_category
    get :show, :id => categories(:how_to).id
    assert_response :success
  end

end
