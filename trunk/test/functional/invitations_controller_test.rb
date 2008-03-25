require File.dirname(__FILE__) + '/../test_helper'
require 'invitations_controller'

# Re-raise errors caught by the controller.
class InvitationsController; def rescue_action(e) raise e end; end

class InvitationsControllerTest < Test::Unit::TestCase
  fixtures :invitations, :users

  def setup
    @controller = InvitationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index, :user_id => users(:quentin).id
    assert_response :success
    assert assigns(:invitations)
  end

  def test_should_get_new
    get :new, :user_id => users(:quentin).id
    assert_response :success
  end


  def test_should_create_invitation_in_welcome_steps
    login_as :quentin
    assert_difference Invitation, :count, 1 do
      post :create, :user_id => users(:quentin).id, :invitation => {:message => 'sup dude', :email_addresses => 'asdf@asdf.com' }, :welcome => 'complete'
      assert_redirected_to welcome_complete_user_path(users(:quentin))
    end    
  end
  
  def test_should_create_invitation
    login_as :quentin
    assert_difference Invitation, :count, 1 do
      post :create, :user_id => users(:quentin).id, :invitation => {:message => 'sup dude', :email_addresses => 'asdf@asdf.com' }
      assert_redirected_to user_path(users(:quentin))
    end    
  end

  def test_should_fail_to_create_invitation
    login_as :quentin
    assert_no_difference Invitation, :count do
      post :create, :user_id => users(:quentin).id, :invitation => {:message => 'sup dude', :email_addresses => nil }
    end    
    assert_response :success
    assert assigns(:invitation).errors.on(:email_addresses)
  end


  def test_should_show_invitation
    get :show, :id => 1, :user_id => users(:quentin).id
    assert_response :success
  end
end
