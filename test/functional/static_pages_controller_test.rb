require File.dirname(__FILE__) + '/../test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  fixtures :users, :static_pages
  # TESTING CRUD ACTIONS
  def test_should_create_static_page
    login_as :admin
    assert_difference StaticPage, :count, +1 do
      post :create, :static_page => {:url => 'url_test'}       
    end
    assert_redirected_to static_page_path(StaticPage.last)
  end

  def test_should_update_static_page
    login_as :admin
    post :create, :static_page => {:url => 'url_test'}       
    assert_no_difference StaticPage, :count do
      post :update, :id => StaticPage.last       
    end
    assert_redirected_to static_page_path(StaticPage.last)   
  end

  def test_should_destroy_static_page
    login_as :admin
    post :create, :static_page => {:url => 'url_test'}       
    assert_difference StaticPage, :count, -1 do
      post :destroy, :id => StaticPage.last       
    end
    assert_redirected_to static_pages_path   
  end

  def test_should_not_create_static_page
    login_as :joe
    assert_no_difference StaticPage, :count do
      post :create, :static_page => {:url => 'url_test'}       
    end 
    assert_redirected_to '/login'
  end

  def test_should_not_destroy_static_page
    login_as :joe
    assert_no_difference StaticPage, :count do
      post :destroy, :id => 1       
    end 
    assert_redirected_to '/login'
  end
  
  def test_should_not_update_static_page
    login_as :joe
    assert_no_difference StaticPage, :count do
      post :update, :id => 1       
    end 
    assert_redirected_to '/login'
  end  
  
   # TESTING SHOW WEB ACTION
  def test_should_show_web_everyone
    all_type_users.each do |user|
      show_web_everyone(user)      
    end
  end

  def test_should_show_web_user
    login_as :quentin
    get :show_web, :url => 'url_test_2'
    assert_response :success
  end

  def test_should_not_show_web_user
    get :show_web, :url => 'url_test_2'
    assert_redirected_to '/login'
  end
  
  def test_should_show_web_admin
    login_as :admin
    get :show_web, :url => 'url_test_3'
    assert_response :success
  end

  def test_should_not_show_web_admin
    no_admin = all_type_users.select {|user| user != users(:admin)}  
    no_admin.each do |user|  
      not_show_web_admin(user)
    end   
  end
  
  def test_should_not_show_no_active
    all_type_users.each do |user|
      not_show_no_active_web(user)
    end
  end

  
  private
  def all_type_users
    [nil,:admin,:quentin,:leopoldo,:joe]
  end
  
  def show_web_everyone(user = nil)
     login_as user  unless user == nil
     get :show_web, :url => 'url_test_1'
     assert_response :success
  end
  
  def not_show_web_admin(user = nil)
    login_as user unless user == nil
    get :show_web, :url => 'url_test_3'
    assert_redirected_to '/login'
  end
  
  def not_show_no_active_web(user = nil)
    login_as user unless user == nil
    get :show_web, :url => 'url_test_4'
    assert_redirected_to '/'
  end
end

