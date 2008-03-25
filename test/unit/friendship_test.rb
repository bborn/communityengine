require File.dirname(__FILE__) + '/../test_helper'

class FriendshipTest < Test::Unit::TestCase
  fixtures :friendships, :users

  def test_user_and_friend_can_not_be_same
    fr = Friendship.new(:user_id => 1, :friend_id => 1)
    assert(!fr.valid?, "Friendship should not be valid")
    assert fr.errors.on(:user_id)
  end
  
  def test_should_prevent_overzealous_frienders
    Friendship.daily_request_limit = 2    
    
    assert Friendship.create!(:user_id => 1, :friend_id => 3, :friendship_status => FriendshipStatus[:pending], :initiator => true)
    assert Friendship.create!(:user_id => 1, :friend_id => 4, :friendship_status => FriendshipStatus[:pending], :initiator => true)
    
    f3 = Friendship.create(:user_id => 1, :friend_id => 5, :friendship_status => FriendshipStatus[:pending], :initiator => true)
    assert(!f3.valid?, "Friendship should not be valid")
    assert_equal f3.errors.on(:base), "Sorry, you'll have to wait a little while before requesting any more friendships."
  end

end
