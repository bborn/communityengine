require File.dirname(__FILE__) + '/../test_helper'

class PagesControllerTest < ActionController::TestCase
  fixtures :pages, :users, :roles

  def test_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:pages)
  end
  
  def test_should_not_get_index_unless_moderator
    login_as :quentin
    get :index
    assert_response :redirect
  end

  def test_should_not_get_index_unless_logged_in
    get :index
    assert_response :redirect
  end

  def test_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end
  
  def test_should_create_page
    login_as :admin
    assert_difference Page, :count, 1 do
      create_page
      assert_response :redirect
    end
  end

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

  def test_should_get_edit
    login_as :admin
    get :edit, :id => pages(:custom_page).id
    assert_response :success
  end
  
  def test_should_update_page
    login_as :admin
    put :update, :id => pages(:custom_page).id, :page => { :title => "changed_name" }
    assert_redirected_to admin_pages_path
    assert_equal assigns(:page).title, "changed_name"
  end

  def test_should_fail_to_update_page
    login_as :admin
    put :update, :id => pages(:custom_page).id, :page => { :title => nil }
    assert_response :success
    assert assigns(:page).errors.on(:title)
  end
  
  def test_should_destroy_page
    login_as :admin
    assert_difference Page, :count, -1 do
      delete :destroy, :id => pages(:custom_page)
    end
    assert_redirected_to admin_pages_path
  end

  def test_should_not_destroy_page
    login_as :aaron
    assert_difference Page, :count, 0 do
      delete :destroy, :id => pages(:custom_page)
    end
    assert_redirected_to login_path
  end

  def create_page(options = {})
    post :create, {:page => { :title => 'New Page', :body => '<p>My new page.</p>', :page_public => true, :published_as => 'live' }.merge(options[:page] || {}) }.merge(options || {})
  end  

end
