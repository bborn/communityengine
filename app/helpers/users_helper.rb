module UsersHelper
  def friends?(user, friend)
    Friendship.friends?(user, friend)
  end    
      
end
