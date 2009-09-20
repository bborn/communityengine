require File.dirname(__FILE__) + '/../test_helper'

class SessionsControllerTest < ActionController::TestCase  
  fixtures :users, :roles

  def test_should_login_and_redirect
    post :create, :login => 'quentin', :password => 'test'
    assert_equal users(:quentin), UserSession.find.record
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :create, :login => 'quentin', :password => 'bad password'
    assert_nil UserSession.find
    assert_response :success
  end

  def test_should_logout
    login_as :quentin
    get :destroy
    assert_nil UserSession.find
    assert_response :redirect
  end

  def test_should_remember_me
    post :create, :login => 'quentin', :password => 'test', :remember_me => "1"
    parsed_cookie = CGI::Cookie.parse(@response.header["Set-Cookie"][0])
    assert parsed_cookie.has_key?('expires')
  end

  def test_should_not_remember_me
    post :create, :login => 'quentin', :password => 'test', :remember_me => "0"
    parsed_cookie = CGI::Cookie.parse(@response.header["Set-Cookie"][0])
    assert !parsed_cookie.has_key?('expires')
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
    post :create, :login => 'quentin', :password => newpass
    assert_equal users(:quentin), UserSession.find.record
  end

end
