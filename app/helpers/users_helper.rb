module UsersHelper
  def friends?(user, friend)
    Friendship.friends?(user, friend)
  end    
  
  def random_greeting(user)
    greetings = [:greeting_1,
    :greeting_2,
    :greeting_3,
    :greeting_4,
    :greeting_5,
    :greeting_6,
    :greeting_7,
    :greeting_8,
    :greeting_9,
    :greeting_10]
    return greetings.sort_by {rand}.first().ll_with_args (:user => user.login)
  end
  
end