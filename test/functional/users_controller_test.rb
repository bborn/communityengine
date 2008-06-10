require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :users, :roles, :tags, :states, :metro_areas, :countries, :skills, :friendship_statuses, :friendships, :categories

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    
    get :index, :tag_name => tags(:misc)
    assert_response :success
    
    get :index, :state_id => states(:minnesota).id
    assert_response :success

    get :index, :metro_area_id => metro_areas(:twincities).id
    assert_response :success
  end
  
  def test_should_get_edit_account
    login_as :quentin
    assert_recognizes({:controller => 'users', :action => 'edit_account'}, {:path => '/account/edit', :method => :get})
    get :edit_account
    assert_response :success
  end  

  def test_should_toggle_moderator
    login_as :admin
    assert !users(:quentin).moderator?
    put :toggle_moderator, :id => users(:quentin)
    assert users(:quentin).reload.moderator?
    put :toggle_moderator, :id => users(:quentin)
    assert !users(:quentin).reload.moderator?
  end

  def test_should_not_toggle_featured_writer_if_not_admin
    login_as :quentin
    put :toggle_moderator, :id => users(:quentin)
    assert_redirected_to :login_url
    assert !users(:quentin).reload.moderator?
  end


  def test_should_toggle_featured_writer
    login_as :admin
    assert !users(:quentin).featured_writer?
    put :toggle_featured, :id => users(:quentin)
    assert users(:quentin).reload.featured_writer?
    put :toggle_featured, :id => users(:quentin)
    assert !users(:quentin).reload.featured_writer?
  end

  def test_should_not_toggle_featured_writer_if_not_admin
    login_as :quentin
    put :toggle_featured, :id => users(:quentin)
    assert_redirected_to :login_url
    assert !users(:quentin).reload.featured_writer?
  end

  def test_should_get_welcome_steps
    login_as :quentin
    
    get :signup_completed, :id => users(:quentin).id
    assert_response :success
    
    get :welcome_photo, :id => users(:quentin).id
    assert_response :success

    get :welcome_about, :id => users(:quentin).id
    assert_response :success

    get :welcome_invite, :id => users(:quentin).id
    assert_response :success

  end

  def test_should_allow_signup
    assert_difference User, :count do
      create_user
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference User, :count do
      create_user( :user => {:login => nil})
      assert assigns(:user).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference User, :count do
      create_user( :user => {:password => nil})
      assert assigns(:user).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference User, :count do
      create_user( :user => {:password_confirmation => nil})
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference User, :count do
      create_user( :user => {:email => nil})
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end
  
  def test_should_not_activate_nil
    get :activate, :activation_code => nil
    assert_response :redirect
  end
  
  def test_should_activate_user
    users(:quentin).activated_at = nil
    users(:quentin).activation_code = nil
    users(:quentin).save!
    assert_nil User.authenticate('quentin', 'test')
    get :activate, :id => users(:quentin).activation_code
    assert_equal users(:quentin), User.authenticate('quentin', 'test')
  end  

  def test_should_fail_to_activate_user
    users(:quentin).activated_at = nil
    users(:quentin).activation_code = nil
    users(:quentin).save!
    assert_nil User.authenticate('quentin', 'test')
    get :activate, :id => 'bad_activation_code'
    assert_equal nil, User.authenticate('quentin', 'test')
  end  

  def test_should_show_user
    get :show, :id => users(:quentin).id
    assert_response :success
  end
  
  def test_should_not_show_private_user
    get :show, :id => users(:privateuser).id
    assert_response :redirect
  end

  def test_should_list_users
    get :index
    assert_equal assigns(:users).size, 10
    assert_response :success
  end
  
  def test_should_fill_states_on_detroit_search
    #state drop down not being enabled
    get :index, :metro_area_id => metro_areas(:Detroit).id
    assert_equal assigns(:states).size, State.count
    assert_response :success
  end
  
  def test_should_empty_states_on_berlin_search
    #state drop down not being enabled
    get :index, :metro_area_id => metro_areas(:berlin).id
    assert_equal assigns(:states).size, 0
    assert_response :success
  end
  
  def test_should_show_edit_form
    login_as :quentin
    get :edit, :id => users(:quentin).id
    assert_response :success
  end
  
  def test_should_not_show_edit_form
    login_as :quentin
    get :edit, :id => users(:aaron)
    assert_redirected_to new_session_path
  end

  
  def test_should_update_user
    login_as :quentin
    put :update, :id => users(:quentin), :user => {:login => "changed_login", :email => "changed_email@email.com"}
    assert_redirected_to user_path(users(:quentin).reload)
    assert_equal assigns(:user).email, "changed_email@email.com"
  end

  def test_should_not_update_user
    login_as :quentin
    put :update, :id => users(:aaron), :user => {:login => "changed_login", :email => "changed_email@email.com"}
    assert_redirected_to new_session_path
  end

  def test_should_destroy_user
    login_as :admin
    assert_difference User, :count, -1 do
      delete :destroy, :id => users(:quentin)
      assert_response :redirect
    end
  end
  
  def test_should_not_destroy_user
    login_as :aaron
    assert_no_difference User, :count do
      delete :destroy, :id => users(:quentin)
      assert_redirected_to login_path
    end    
  end
  
  def test_should_never_destroy_admin
    login_as :admin
    assert_no_difference User, :count do
      delete :destroy, :id => users(:admin)
      assert_response :redirect
    end    
  end

  def test_should_upload_avatar
    login_as :quentin
    put :update, :id => users(:quentin).id, :user => {}, :avatar => {:uploaded_data => fixture_file_upload('/files/library.jpg', 'image/jpg')}
    assert users(:quentin).reload.avatar.filename, "library.jpg"
  end
  
  def test_should_not_delete_existing_avatar_if_file_field_is_blank
    login_as :quentin
    put :update, :id => users(:quentin).id, :user => {}, :avatar => {:uploaded_data => fixture_file_upload('/files/library.jpg', 'image/jpg')}
    assert users(:quentin).reload.avatar.filename, "library.jpg"

    put :update, :id => users(:quentin).id, :user => {}
    assert users(:quentin).reload.avatar.filename, "library.jpg"
  end
  
  def test_create_friendship_with_invited_user
    assert_difference User, :count do
      assert_difference Friendship, :count, 2 do
        create_user({:inviter_code => users(:quentin).invite_code , :inviter_id => users(:quentin).id })
      end
    end
    assert_response :redirect    
  end
    
  def test_should_update_account
    login_as :quentin
    put :update_account, :user => {:login => 'changed_login'}, :id => users(:quentin)
    assert_redirected_to user_path(users(:quentin).reload)
    assert_equal assigns(:user).login, 'changed_login'
  end
  
  def test_should_reset_password
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      post :forgot_password, :email => users(:quentin).email
      assert_redirected_to login_path    
    end
  end

  def test_should_remind_username
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      post :forgot_username, :email => users(:quentin).email
      assert_redirected_to login_path    
    end
  end
  
  def test_assume_should_assume_users_id
    login_as :admin
    post :assume, :id => users(:quentin).id
    assert_response :redirect
    assert_equal session[:user], users(:quentin).id
    assert_not_nil session[:admin_id]
    assert_equal users(:admin).id, session[:admin_id]
  end
  
  def test_only_admin_can_assume_id
    login_as :quentin
    post :assume, :id => users(:aaron).id
    assert_response :redirect
    assert_not_equal session[:user], users(:aaron).id
    assert_nil session[:admin_id]
  end
  
  def test_return_admin_should_set_user_to_admin
    login_as :quentin
    @request.session[:admin_id] = users(:admin).id
    post :return_admin
    assert_response :redirect
    assert_nil session[:admin_id]
    assert_equal users(:admin).id, session[:user]
  end
  
  def test_only_admin_can_return_to_admin
    login_as :quentin
    @request.session[:admin_id] = users(:admin).id
    post :return_admin
    assert_response :redirect
    assert_nil session[:admin_id]
    assert_equal users(:admin).id, session[:user]    
  end
  
  def test_should_decrement_metro_area_count
    initial_count = metro_areas(:twincities).users_count
    quentin = users(:quentin)
    quentin.metro_area = metro_areas(:Detroit)
    quentin.save
    assert_equal(metro_areas(:twincities).reload.users_count, metro_areas(:twincities).reload.users.size )
    assert_equal(metro_areas(:Detroit).reload.users_count, metro_areas(:Detroit).reload.users.size )
  end  
  
  def test_should_increment_metro_area_count
    initial_count = metro_areas(:Detroit).users_count
    aaron = users(:aaron)
    aaron.metro_area = metro_areas(:Detroit)
    aaron.save
    assert_equal metro_areas(:Detroit).reload.users_count, initial_count + 1
    assert_equal(metro_areas(:Detroit).reload.users_count, metro_areas(:Detroit).reload.users.size )
  end  
  
  def test_should_get_stats_if_admin
    login_as :admin
    get :statistics, :id => users(:super_writer).id
    assert_response :success
  end

  def test_should_not_get_stats_if_not_admin
    login_as :quentin
    get :statistics, :id => users(:super_writer).id
    assert_response :redirect
  end

  def test_should_get_dashboard_with_no_friends
    login_as :aaron
    assert users(:aaron).network_activity.empty?
    get :dashboard, :id => users(:aaron).login_slug
    assert_response :success
  end

  def test_should_get_dashboard_with_no_recommended_posts
    login_as :quentin
    users(:aaron).tag_with('hansel gretel')
    assert !users(:aaron).tags.empty?

    assert users(:aaron).recommended_posts.empty?    
    get :dashboard, :id => users(:aaron).login_slug
    assert_response :success
  end

  
  protected
    def create_user(options = {})
      post :create, {:user => { :login => 'quire', :email => 'quire@example.com', 
        :password => 'quire123', :password_confirmation => 'quire123',
        :birthday => 15.years.ago
         }.merge(options[:user] || {}) }.merge(options || {})
    end
        
end
