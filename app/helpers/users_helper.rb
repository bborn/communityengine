module UsersHelper
  def friends?(user, friend)
    Friendship.friends?(user, friend)
  end    
  
  def random_greeting(user)
    greetings = ['Hello', 'Hola', 'Hi ', 'Yo', 'Welcome back,', 'Greetings',
        'Wassup', 'Aloha', 'Halloo']
    "#{greetings.sort_by {rand}.first} #{user.login}!"
  end
  
  def time_ago_in_words_or_date(date)
    if date.to_date.eql?(Time.now.to_date)
      display = date.strftime("%l:%M%p").downcase
    elsif date.to_date.eql?(Time.now.to_date - 1)
      display = "Yesterday"
    else
      display = date.strftime("%B %d")
    end
  end
  
end