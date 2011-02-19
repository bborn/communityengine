require 'test_helper'

class AuthorizationTest < ActiveSupport::TestCase
  fixtures :all  

  test "should create new User and Authorization from hash" do
    assert_difference User, :count, 1 do
      assert_difference Authorization, :count, 1 do
        Authorization.create_from_hash(auth_hash)              
      end
    end
  end
  
  test "should create Authorization for existing user with hash" do
    assert_difference users(:quentin).authorizations, :count, 1 do
      assert_difference Authorization, :count, 1 do
        Authorization.create_from_hash(auth_hash, users(:quentin))              
      end      
    end
  end
  
  
  def auth_hash
    hash = {
      'provider' => 'twitter',
      'uid' => '12345',
      'user_info' => {
        'nickname' => 'omniauthuser',
        'email' => 'email@example.com'        
      }
    }    
  end

end