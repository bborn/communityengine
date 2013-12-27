require 'test_helper'

class AuthorizationsControllerTest < ActionController::TestCase
  fixtures :all

  setup do
    OmniAuth.config.test_mode = true
  end



  test 'should create new authorization and log in' do

    set_ommniauth

    get :create

    user = UserSession.find.record
    assert_redirected_to user_path(user)
  end

  test 'should find existing authorization and log in' do
    quentin = users(:quentin)
    Authorization.create_from_hash(auth_hash(quentin.email), quentin)
    set_ommniauth(quentin.email)

    get :create

    assert_redirected_to user_path(quentin)
  end

  test 'should authorize existing logged-in user' do
    quentin = users(:quentin)
    login_as :quentin

    set_ommniauth(quentin.email)

    get :create

    assert_redirected_to user_path(quentin)
  end


  def set_ommniauth(email=nil)
    OmniAuth.config.mock_auth[:facebook] = auth_hash(email)
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
  end

  def auth_hash(email='email@example.com')
    {
      'provider' => 'facebook',
      "info" => {
        'nickname'  => 'Omniauth-user',
        'email' => email
      },
      'uid' => '123545'
    }
  end

end
