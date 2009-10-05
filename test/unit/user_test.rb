require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  fixtures :all

  def test_should_create_user
    assert_difference User, :count do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end
  
  def test_should_trim_whitespace
    user = users(:quentin)
    user.login = 'quentin    '
    user.save!
    assert_equal user.login, 'quentin'
  end

  def test_should_not_reject_spaces
    user = User.new(:login => 'foo bar')
    user.valid?
    assert !user.errors.on(:login)
  end

  def test_should_reject_special_chars
    user = User.new(:login => '&stripes')
    assert !user.valid?
    assert user.errors.on(:login)
  end
  
  def test_should_accept_normal_chars_in_login
    u = create_user(:login => "foo_and_bar")
    assert !u.errors.on(:login)
    u = create_user(:login => "2foo-and-bar")
    assert !u.errors.on(:login)
  end

  def test_should_require_login
    assert_no_difference User, :count do
      u = create_user(:login => nil)
      assert u.errors.on(:login)
    end
  end
  
  def test_should_find_user_with_numerals_in_login
    u = create_user(:login => "2foo-and-bar")
    assert !u.errors.on(:login)
    assert_equal u, User.find("2foo-and-bar")
  end
  
  def test_login_slug_should_be_unique
    u = create_user(:login => 'user-name')
    u2 = create_user(:login => 'user_name')    
    
    assert u.login_slug != u2.login_slug
  end
  
  def test_should_require_password
    assert_no_difference User, :count do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference User, :count do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference User, :count do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end
  
  def test_should_require_birthday
    assert_no_difference User, :count do
      u = create_user(:birthday => nil)
      assert u.errors.on(:birthday)
    end
  end  

  def test_should_handle_email_upcase
    assert_difference User, :count, 1 do
      assert create_user(:email => 'BENMOORE@BENMOORE.NET').valid?
    end
  end

  def test_should_reset_password
    activate_authlogic
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:quentin), UserSession.create(:login => 'quentin', :password => 'new password').record
  end

  def test_should_not_rehash_password
    activate_authlogic
    users(:quentin).update_attributes(:login => 'quentin_two')
    assert_equal users(:quentin), UserSession.create(:login => 'quentin_two', :password => 'test').record
  end

  def test_should_show_location
    assert_equal users(:quentin).location, metro_areas(:twincities).name
  end
  
  def test_should_call_avatar_photo
    assert_equal users(:quentin).avatar_photo_url, AppConfig.photo['missing_medium']
    assert_equal users(:quentin).avatar_photo_url(:thumb), AppConfig.photo['missing_thumb']
  end
    
  def test_should_find_featured
    featured = User.find_featured
    assert_equal featured.size, 1
  end

  def test_should_find_by_activity
    assert_difference Activity, :count, 3 do
      users(:quentin).track_activity(:logged_in)
      users(:quentin).track_activity(:logged_in)
      users(:quentin).track_activity(:logged_in)            
    end

    assert !User.find_by_activity({:require_avatar => false}).empty?
    
    users(:quentin).update_attribute(:avatar_id, 1) #just pretend
    assert !User.find_by_activity.empty?    
  end
  
  def test_should_update_activities_counter_on_user
    #make sure the initial count is right
    Activity.destroy_all
    users(:quentin).update_attribute( :activities_count, Activity.by(users(:quentin)) )
    
    assert_difference users(:quentin), :activities_count, 1 do
      users(:quentin).track_activity(:logged_in)
      users(:quentin).reload
    end
  end


  def test_should_have_reached_daily_friend_request_limit
    Friendship.daily_request_limit = 1
    
    assert !users(:quentin).has_reached_daily_friend_request_limit?
    f = Friendship.create!(:user => users(:quentin), :friend => users(:kevin), :initiator => true, :friendship_status => FriendshipStatus[:pending])
    assert users(:quentin).has_reached_daily_friend_request_limit?
  end
  
  def test_get_network_activity
    users(:aaron).track_activity(:logged_in) #create an activity
        
    u = users(:quentin)
    f = friendships(:aaron_receive_quentin_pending)
    f.update_attributes(:friendship_status => FriendshipStatus[:accepted]) && f.reverse.update_attributes(:friendship_status => FriendshipStatus[:accepted])
    assert !u.network_activity.empty?    
  end
  
  def test_comments_activity
    user = users(:quentin)
    
    #might be a good idea to check if there are any comments_activity objects beforehand
    #assert_equal 0, user.comments_activity.size
    
    2.times do
      comment = Comment.create!(:comment => "foo", :user => users(:aaron), :commentable => user, :recipient => user)
    end
    
    assert_equal 2, user.comments_activity.size
  end
  
  def test_should_deactivate
    assert users(:quentin).active?
    users(:quentin).deactivate
    assert !users(:quentin).reload.active?
  end

  def test_should_return_full_location
    assert_equal "Minneapolis / St. Paul", users(:quentin).full_location    
  end
  
  def test_should_prohibit_reserved_logins    
    user = create_user(:login => 'contests')
    assert !user.valid?
  end

  
  protected
    def create_user(options = {})
      User.create({ :login => 'quire', 
          :email => 'quire@example.com', :password => 'quire123', :password_confirmation => 'quire123', :birthday => 14.years.ago }.merge(options))
    end
end
