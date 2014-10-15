require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :all

  test "should_create_user" do
    assert_difference User, :count do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end


  test "should prevent malicious chars inserted in email via newlines" do
    user = User.new(:email => "valid@email.com%0A<script>alert('hello')</script>")
    assert !user.valid?
    assert user.errors[:email]
  end

  test "should prevent malicious chars inserted in login via newlines" do
    user = User.new(:login => "validlogin%0A<script>alert('hello')</script>")
    assert !user.valid?
    assert user.errors[:email]
  end

  test "should_trim_whitespace" do
    user = users(:quentin)
    user.login = 'quentin    '
    user.save!
    assert_equal user.login, 'quentin'
  end

  test "should_not_reject_spaces" do
    user = User.new(:login => 'foo bar')
    user.valid?
    assert user.errors[:login].empty?
  end

  test "should_reject_special_chars" do
    user = User.new(:login => '&stripes')
    assert !user.valid?
    assert user.errors[:login]
  end

  test "should_accept_normal_chars_in_login" do
    u = create_user(:login => "foo_and_bar")
    assert u.errors[:login].empty?
    u = create_user(:login => "2foo-and-bar")
    assert u.errors[:login].empty?
  end

  test "should_require_login" do
    assert_no_difference User, :count do
      u = create_user(:login => nil)
      assert u.errors[:login]
    end
  end

  test "should_find_user_with_numerals_in_login" do
    u = create_user(:login => "2foo-and-bar")
    assert u.errors[:login].empty?
    assert_equal u, User.find("2foo-and-bar")
  end

  test "should_require_password" do
    assert_no_difference User, :count do
      u = create_user(:password => nil)
      assert u.errors[:password]
    end
  end

  test "should_require_password_confirmation" do
    assert_no_difference User, :count do
      u = create_user(:password_confirmation => nil)
      assert u.errors[:password_confirmation]
    end
  end

  test "should_require_email" do
    assert_no_difference User, :count do
      u = create_user(:email => nil)
      assert u.errors[:email]
    end
  end

  test "should_require_valid_birthday" do
    assert_no_difference User, :count do
      u = create_user(:birthday => 1.year.ago)
      assert u.errors[:birthday].any?
    end
  end

  test "should_handle_email_upcase" do
    assert_difference User, :count, 1 do
      assert create_user(:email => 'FOO@BAR.NET').valid?
    end
  end

  test "should_update_password" do
    activate_authlogic
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:quentin), UserSession.create(:login => 'quentin', :password => 'new password').record
  end

  test "should deliver password reset instructions" do
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      users(:quentin).deliver_password_reset_instructions!
    end
  end

  test "should_not_rehash_password" do
    activate_authlogic
    users(:quentin).update_attributes(:login => 'quentin_two')
    assert_equal users(:quentin), UserSession.create(:login => 'quentin_two', :password => 'test').record
  end

  test "should_show_location" do
    assert_equal users(:quentin).location, metro_areas(:twincities).name
  end

  test "should_call_avatar_photo" do
    assert_equal users(:quentin).avatar_photo_url, configatron.photo.missing_medium
    assert_equal users(:quentin).avatar_photo_url(:thumb), configatron.photo.missing_thumb
  end

  test "should_find_featured" do
    featured = User.find_featured
    assert_equal featured.size, 1
  end

  test "should_find_by_activity" do
    assert_difference Activity, :count, 3 do
      users(:quentin).track_activity(:logged_in)
      users(:quentin).track_activity(:logged_in)
      users(:quentin).track_activity(:logged_in)
    end

    assert !User.find_by_activity({:require_avatar => false}).empty?

    users(:quentin).update_attribute(:avatar_id, 1) #just pretend
    assert !User.find_by_activity.empty?
  end

  test "should_not_include_inactive_users_in_find_by_activity" do
    inactive_user = create_user
    assert !inactive_user.active?
    Activity.create(:user => inactive_user)
    assert_nothing_raised do
      User.find_by_activity({:limit => 5, :require_avatar => false})
    end
  end


  test "should_update_activities_counter_on_user" do
    #make sure the initial count is right
    Activity.destroy_all
    users(:quentin).update_attribute( :activities_count, Activity.by(users(:quentin)) )

    assert_difference users(:quentin), :activities_count, 1 do
      users(:quentin).track_activity(:logged_in)
      users(:quentin).reload
    end
  end


  test "should_have_reached_daily_friend_request_limit" do
    Friendship.daily_request_limit = 1

    assert !users(:quentin).has_reached_daily_friend_request_limit?
    f = Friendship.create!(:user => users(:quentin), :friend => users(:kevin), :initiator => true, :friendship_status => FriendshipStatus[:pending])
    assert users(:quentin).has_reached_daily_friend_request_limit?
  end

  test "get_network_activity" do
    users(:aaron).track_activity(:logged_in) #create an activity

    u = users(:quentin)
    f = friendships(:aaron_receive_quentin_pending)
    f.update_attributes(:friendship_status => FriendshipStatus[:accepted]) && f.reverse.update_attributes(:friendship_status => FriendshipStatus[:accepted])
    assert !u.network_activity.empty?
  end

  test "should_get_comments_activity" do
    user = users(:quentin)

    2.times do
      comment = user.comments.create!(:comment => "foo", :user => users(:aaron), :recipient => user)
    end

    assert_equal 2, user.comments_activity.size
  end

  test "should_deactivate" do
    assert users(:quentin).active?
    users(:quentin).deactivate
    assert !users(:quentin).reload.active?
  end

  test "should activate and send email" do
    #make quentin inactive
    users(:quentin).deactivate
    assert !users(:quentin).reload.active?

    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      users(:quentin).activate
      assert users(:quentin).reload.active?
    end
  end

  test "should_return_full_location" do
    assert_equal "Minneapolis / St. Paul", users(:quentin).full_location
  end

  test "should_prohibit_reserved_logins    " do
    user = create_user(:login => configatron.reserved_logins.first)
    assert !user.valid?
  end

  test "should find user tagged with a tag" do
    user = users(:quentin)
    user.tag_list = 'foo'
    user.save

    assert User.tagged_with('foo').include?(user)
  end


  test "should prepare params for search" do
    params = User.prepare_params_for_search(:metro_area_id => 1, :state_id => 1)
    assert_equal(params, {:metro_area_id=>1, :state_id=>1, "metro_area_id"=>1, "state_id"=>1, "country_id"=>nil})
  end

  test "should build scope for search params" do
    params = {'country_id' => 1, 'state_id' => 1, 'metro_area_id' => 1, 'login' => 'foo', 'vendor' => false, 'description' => 'baz'}
    scope = User.build_conditions_for_search(params)

    #This sucks; I want to make sure that the correct scopes are set up on the relation, but I don't know a better way.
    assert_equal("SELECT \"users\".* FROM \"users\"  WHERE (users.activated_at IS NOT NULL) AND \"users\".\"metro_area_id\" = 1 AND (\"users\".\"login\" LIKE '%foo%') AND (\"users\".\"description\" LIKE '%baz%')", scope.to_sql)
  end

  test "should create user from authorization" do
    hash = {'provider' => 'twitter',
      'uid' => '12345',
      'nickname' => 'omniauthuser',
      'email' => 'email@example.com' }

    Authorization.create!(hash) do |auth|
      assert_difference User, :count, 1 do
        user = User.find_or_create_from_authorization(auth)
        auth.user = user
      end
    end

  end

  test "should not require password or email for omniauthed user" do
    user = User.new
    user.authorizing_from_omniauth = true
    user.valid?
    assert(user.errors[:email].empty?, "Should not have errors on email")
    assert(user.errors[:birthday].empty?, "Should not have errors on birthday")
  end

  protected
    def create_user(options = {})
      User.create({
        :login => 'quire',
        :email => 'quire@example.com',
        :password => 'quire123',
        :password_confirmation => 'quire123',
        :birthday => configatron.min_age.years.ago }.merge(options))
    end
end
