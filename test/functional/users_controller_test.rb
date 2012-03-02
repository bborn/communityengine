require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  fixtures :all

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
    assert_redirected_to login_url
    assert !users(:quentin).reload.featured_writer?
  end

  def test_should_get_signup_completed
    login_as :quentin
    
    get :signup_completed, :id => users(:quentin)
    assert_response :success
  end
  
  def test_should_get_welcome_photo
    login_as :quentin  
    get :welcome_photo, :id => users(:quentin).id
    assert_response :success
  end
  
  def test_should_get_welcome_about
    login_as :quentin
    get :welcome_about, :id => users(:quentin).id
    assert_response :success
  end
  
  def test_should_get_welcome_invite
    login_as :quentin
    get :welcome_invite, :id => users(:quentin).id
    assert_response :success
  end
  
  def test_should_get_new
    get :new
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
      assert assigns(:user).errors[:login]
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference User, :count do
      create_user( :user => {:password => nil})
      assert assigns(:user).errors[:password]
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference User, :count do
      create_user( :user => {:password_confirmation => nil})
      assert assigns(:user).errors[:password_confirmation]
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference User, :count do
      create_user( :user => {:email => nil})
      assert assigns(:user).errors[:email]
      assert_response :success
    end
  end
  
  def test_should_render_new_form_when_signing_up_without_required_attributes
    create_user(:user => {:password => nil})
    assert_response :success
  end

  def test_should_deactivate_and_logout
    login_as :quentin
    assert users(:quentin).active?
    put :deactivate, :id => users(:quentin).id
    assert !users(:quentin).reload.active?    
    assert_redirected_to login_path
  end
    
  def test_should_activate_user
    users(:quentin).activated_at = nil
    users(:quentin).activation_code = ':quentin_activation_code'
    users(:quentin).save!
    login_as :quentin
    assert_nil UserSession.find
    
    users(:quentin).activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    users(:quentin).save!
    
    get :activate, :id => users(:quentin).activation_code
    assert_equal users(:quentin), UserSession.find.record
  end  

  def test_should_fail_to_activate_user
    users(:quentin).activated_at = nil
    users(:quentin).activation_code = nil
    users(:quentin).save!
    login_as :quentin
    assert_nil UserSession.find

    get :activate, :id => 'bad_activation_code'
    assert_nil UserSession.find
  end  

  def test_should_show_user
    get :show, :id => users(:quentin)
    assert_response :success
  end
  
  def test_should_not_show_private_user
    get :show, :id => users(:privateuser).id
    assert_response :redirect
  end

  def test_should_list_users
    get :index
    assert_equal assigns(:users).size, 13
    
    assert_response :success
  end
  
  def test_should_fill_states_on_detroit_search
    #state drop down not being enabled
    get :index, :metro_area_id => metro_areas(:detroit).id
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
    assert_redirected_to login_path
  end

  def test_should_update_user
    login_as :quentin
    put :update, :id => users(:quentin), :user => {:email => "changed_email@email.com"}
    assert_redirected_to user_path(users(:quentin).reload)
    assert_equal assigns(:user).email, "changed_email@email.com"
  end

  def test_should_update_user_tags
    login_as :quentin
    users(:quentin).tag_list = ''
    users(:quentin).save
    put :update, :id => users(:quentin), :tag_list => 'tag1, tag2', :user => {}
    assert_redirected_to user_path(users(:quentin).reload)
    assert_equal users(:quentin).tag_list, ['tag1', 'tag2']
  end

  def test_should_not_update_user
    login_as :quentin
    put :update, :id => users(:aaron), :user => {:login => "changed_login", :email => "changed_email@email.com"}
    assert_redirected_to login_path
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
    put :update, :id => users(:quentin).id, :user => {:avatar_attributes => {:photo => fixture_file_upload('/files/library.jpg', 'image/jpg')}}
    assert users(:quentin).reload.avatar.photo_file_name, "library.jpg"
  end
  
  def test_should_not_delete_existing_avatar_if_file_field_is_blank
    login_as :quentin
    put :update, :id => users(:quentin).id, :user => {:avatar_attributes => {:photo => fixture_file_upload('/files/library.jpg', 'image/jpg')}}
    assert users(:quentin).reload.avatar.photo_file_name, "library.jpg"

    put :update, :id => users(:quentin).id, :user => {}
    assert users(:quentin).reload.avatar.photo_file_name, "library.jpg"
  end
  
  def test_should_crop_profile_photo
    login_as :quentin
    avatar = Photo.new(:photo => fixture_file_upload('/files/library.jpg', 'image/jpg'))
    avatar.user = users(:quentin)
    avatar.save!

    users(:quentin).avatar = avatar
    users(:quentin).save
    
    put :crop_profile_photo, :id => users(:quentin).id, :x1 => 0, :y1 => 0, :width => 290, :height => 320
    
    assert_redirected_to user_path(users(:quentin))
  end
  
  def test_should_upload_profile_photo
    login_as :quentin

    put :upload_profile_photo, :id => users(:quentin), :avatar => {:photo => fixture_file_upload('/files/library.jpg', 'image/jpg')}
    
    assert_redirected_to crop_profile_photo_user_path(users(:quentin).reload)    
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
  
  def test_should_remind_username
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      post :forgot_username, :email => users(:quentin).email
      assert_redirected_to login_path    
    end
  end
  
  def test_should_resend_activation
    users(:quentin).activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    users(:quentin).activated_at = nil
    users(:quentin).save!
    
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      post :resend_activation, :id => users(:quentin)
      assert_redirected_to login_path    
    end    
  end
  
  def test_should_not_resend_activation_for_active_user
    assert_no_difference ActionMailer::Base.deliveries, :length do
      post :resend_activation, :id => users(:quentin).to_param
      assert_response :success
      assert_equal :activation_email_not_sent_message.l, flash[:notice]
    end    
  end

  def test_should_not_resend_activation_for_nonexistent_user
    assert_no_difference ActionMailer::Base.deliveries, :length do
      assert_raise(ActiveRecord::RecordNotFound) {  
        post :resend_activation, :id => "nonexistant"
      }
    end    
  end

  def test_assume_should_assume_users_id
    login_as :admin
    post :assume, :id => users(:quentin)
    assert_response :redirect
    assert_equal UserSession.find.record, users(:quentin)
    assert_not_nil session[:admin_id]
    assert_equal users(:admin).id, session[:admin_id]
  end
  
  def test_only_admin_can_assume_id
    login_as :quentin
    post :assume, :id => users(:aaron).id
    assert_response :redirect
    assert_not_equal UserSession.find.record, users(:aaron)
    assert_nil session[:admin_id]
  end

  def test_only_admin_can_assume_id_js
    login_as :quentin
    post :assume, :id => users(:aaron).id, :format => 'js'
    assert_response :success
    assert_not_equal UserSession.find.record, users(:aaron)
    assert_nil session[:admin_id]
  end
  
  def test_return_admin_should_set_user_to_admin
    login_as :quentin
    @request.session[:admin_id] = users(:admin).id
    post :return_admin
    assert_response :redirect
    assert_nil session[:admin_id]
    assert_equal users(:admin), UserSession.find.record
  end
  
  def test_only_admin_can_return_to_admin
    login_as :quentin
    @request.session[:admin_id] = users(:admin).id
    post :return_admin
    assert_response :redirect
    assert_nil session[:admin_id]
    assert_equal users(:admin), UserSession.find.record
  end
  
  def test_should_decrement_metro_area_count
    initial_count = metro_areas(:twincities).users_count
    quentin = users(:quentin)
    quentin.metro_area = metro_areas(:detroit)
    quentin.save
    assert_equal(metro_areas(:twincities).reload.users_count, metro_areas(:twincities).reload.users.size )
    assert_equal(metro_areas(:detroit).reload.users_count, metro_areas(:detroit).reload.users.size )
  end  
  
  def test_should_increment_metro_area_count
    initial_count = metro_areas(:detroit).users_count
    aaron = users(:aaron)
    aaron.metro_area = metro_areas(:detroit)
    aaron.save!
    assert_equal metro_areas(:detroit).reload.users_count, initial_count + 1
    assert_equal(metro_areas(:detroit).reload.users_count, metro_areas(:detroit).reload.users.size )
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
  
  def test_should_get_with_date_param
    login_as :admin
    post = users(:quentin).posts.last
    get :statistics, :id => users(:quentin).id, :date => {:year => post.published_at.year, :month => post.published_at.month}
    assert_response :success
    assert !assigns(:posts).empty?
  end
  

  def test_should_get_dashboard_with_no_friends
    login_as :aaron
    assert users(:aaron).network_activity.empty?
    get :dashboard, :id => users(:aaron).friendly_id
    assert_response :success
  end

  def test_should_get_dashboard_with_no_recommended_posts
    login_as :quentin
    users(:aaron).tag_list = 'hansel, gretel'
    users(:aaron).save
    assert !users(:aaron).tags.empty?

    assert users(:aaron).recommended_posts.empty?    
    get :dashboard, :id => users(:aaron).friendly_id
    assert_response :success
  end

  def test_should_show_user_statistics
    login_as :admin
    get :statistics, :id => users(:quentin).id
    assert_response :success
  end
  
  test 'should delete selected users in admin users action' do
    login_as :admin
    assert_difference User, :count, -1 do
      post :delete_selected, :delete => [users(:florian).id]
    end
    assert_redirected_to admin_users_path
  end

  test 'should store location for anonymous page' do
    return_to = session[:return_to]
    get :index
    assert_not_equal return_to, session[:return_to]
    assert_equal "http://test.host/users", session[:return_to]
  end

  
  protected
    def create_user(options = {})
      params = {:user => {:login => 'quire', :email => 'quire@example.com', :password => 'quire123', :password_confirmation => 'quire123', :birthday => configatron.min_age.years.ago}}
      user_opts = options.delete(:user)
      params[:user].merge!(user_opts) if user_opts
    
      post :create, params.merge(options)
    end
        
end
