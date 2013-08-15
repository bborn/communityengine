require 'test_helper'

class SessionsControllerTest < ActionController::TestCase  
  fixtures :all

  def test_should_login_and_redirect
    post :create, :email => 'quentin@example.com', :password => 'test'
    assert_equal users(:quentin), UserSession.find.record
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :create, :email => 'quentin@example.com', :password => 'bad password'
    assert_nil UserSession.find
    assert_response :success
  end

  def test_should_logout
    login_as :quentin
    get :destroy
    assert_nil UserSession.find
    assert_response :redirect
  end
  
  def test_should_delete_token_on_logout
    login_as :quentin
    get :destroy
    assert_equal @response.cookies["user_credentials"], nil
  end

  def test_should_login_with_cookie
    @request.cookies["user_credentials"] = {:value => {:value => users(:quentin).persistence_token}, :expires => nil}
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    @request.cookies["user_credentials"] = {:value => {:value => users(:quentin).persistence_token}, :expires => 5.minutes.ago.utc}
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    @request.cookies["user_credentials"] = {:value => {:value => 'invalid_token'}, :expires => nil}
    assert !@controller.send(:logged_in?)
  end
  
  def test_should_login_with_reset_password
    quentin = users(:quentin)
    quentin.reset_password
    newpass = quentin.password
    quentin.save_without_session_maintenance
    post :create, :email => 'quentin@example.com', :password => newpass
    assert_equal users(:quentin), UserSession.find.record
  end

  test 'should login and not store location' do
    return_to = session[:return_to]
    post :create, :email => 'quentin@example.com', :password => 'test'
    assert_equal return_to, session[:return_to]
  end

  test 'should logout and destroy session' do
    login_as :quentin
    assert !session.empty?
    get :destroy
    # The session will not be empty because the flash message will be in it.
    #
    #assert session.empty?
    assert session[:user_credentials].nil?
  end

end

