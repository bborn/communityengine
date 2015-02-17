require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  fixtures :all


  def test_should_show_public_page_to_everyone
    get :show, :id => pages(:custom_page).id
    assert_response :success
  end

  def test_should_not_show_draft
    pages(:draft_page).save_as_draft
    get :show, :id => pages(:draft_page).id
    assert_response :redirect
  end


  def test_should_not_show_members_only_page_unless_logged_in
    get :show, :id => pages(:members_only_page).id
    assert_response :redirect
  end

end
