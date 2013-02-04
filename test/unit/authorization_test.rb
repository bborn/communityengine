require 'test_helper'

class AuthorizationTest < ActiveSupport::TestCase
  fixtures :all  
  
  test "should find existing from hash" do
    auth = Authorization.create_from_hash(auth_hash)    
    assert_equal(auth.email, 'email@example.com')
    existing = Authorization.find_or_create_from_hash(auth_hash.merge('info' => {'email' => 'changed@example.com'}))
    assert_equal(auth, existing)
    assert_equal(existing.email, 'changed@example.com')    
  end
  
  test "should create new Authorization and User from hash" do
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
  
  test "should allow authorization to be destroyed" do
    authorization1 = Authorization.create_from_hash(auth_hash, users(:quentin))              
    authorization2 = Authorization.create_from_hash(auth_hash.merge('provider' => 'facebook'), users(:quentin))                      
    
    assert authorization2.destroy
    assert authorization2.errors[:base].empty?, 'Authorization should have not have an error on :base'    
  end
  
  
  test "should not allow authorization to be destroyed if it's the only one left and the user would be invalid without it" do
    authorization = Authorization.create_from_hash(auth_hash, users(:quentin))              
    authorization.destroy    
    assert !authorization.errors[:base].empty?, 'Authorization should have an error on :base'
  end
  
  def auth_hash
    OmniAuth.config.mock_auth[:default].merge({ 'provider' => 'twitter',
      'uid' => '12345',
      'info' => {
        'nickname' => 'omniauthuser',
        'email' => 'email@example.com'        
      }
    })
  end

end