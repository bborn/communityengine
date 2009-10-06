module UsersHelper
  def friends?(user, friend)
    Friendship.friends?(user, friend)
  end    
  
  def random_greeting(user)
    "#{:greetings.l.sort_by {rand}.first} #{user.login}!"
  end
    
end
