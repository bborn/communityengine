require File.dirname(__FILE__) + '/../test_helper'
require 'skills_controller'

# Re-raise errors caught by the controller.
class SkillsController; def rescue_action(e) raise e end; end

class SkillsControllerTest < Test::Unit::TestCase
  fixtures :skills, :users

  def setup
    @controller = SkillsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:skills)
  end

  def test_should_get_non_logged_in_pages
    get :index
    assert_response :success
    get :show, :id => 1
    assert_response :success

    post :create, :skill => {:name => 'plumbing'}
    assert_response :redirect
    put :update, :id => 1, :skill => {:name => 'Welding' }
    assert_response :redirect
  end

  def test_should_get_non_admin_pages
    login_as :quentin
    post :create, :skill => {:name => 'plumbing'}
    assert_response :redirect
    put :update, :id => 1, :skill => {:name => 'Welding' }
    assert_response :redirect
  end

  def test_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end
  
  def test_should_fail_to_get_new
    login_as :quentin
    get :new
    assert_response :redirect
  end
  
  def test_should_create_skill
    login_as :admin
    assert_difference Skill, :count, 1 do
      post :create, :skill => {:name => 'Soldering'}
      assert_response :redirect
    end
  end

  def test_should_require_unique_name
    login_as :admin
    assert_no_difference Skill, :count do
      post :create, :skill => {:name => 'plumbing'}
    end
  end

  def test_should_show_skill
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    login_as :admin
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_skill
    login_as :admin
    put :update, :id => 1, :skill => {:name => 'Welding' }
    assert_redirected_to skill_path(assigns(:skill))
  end
  
  def test_should_destroy_skill
    login_as :admin
    old_count = Skill.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Skill.count
    
    assert_redirected_to skills_path
  end

end
