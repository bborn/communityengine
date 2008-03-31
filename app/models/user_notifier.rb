class UserNotifier < ActionMailer::Base
  default_url_options[:host] = APP_URL.sub('http://', '')
  include ActionController::UrlWriter
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper  
  include BaseHelper
  
  def signup_invitation(email, user, message)
    setup_sender_info
    @recipients  = "#{email}"
    @subject     = "#{user.login} would like you to join #{AppConfig.community_name}!"
    @sent_on     = Time.now
    @body[:user] = user
    @body[:url]  = user.generate_invite_url    
    @body[:message] = message
  end

  def friendship_request(friendship)
    setup_sender_info
    @recipients  = "#{friendship.friend.email}"
    @subject     = "#{friendship.user.login} would like to be friends with you on #{AppConfig.community_name}!"
    @sent_on     = Time.now
    @body[:url]  = friendship.generate_url
    @body[:user] = friendship.friend
    @body[:requester] = friendship.user
  end

  def comment_notice(comment)
    @recipients  = "#{comment.recipient.email}"
    setup_sender_info
    @subject     = "#{comment.user.login} has something to say to you on #{AppConfig.community_name}!"
    @sent_on     = Time.now
    @body[:url]  = comment.generate_commentable_url
    @body[:user] = comment.recipient
    @body[:comment] = comment
    @body[:commenter] = comment.user
  end
  
  def follow_up_comment_notice(user, comment)
    @recipients  = "#{user.email}"
    setup_sender_info
    @subject     = "#{comment.user.login} has commented on a #{comment.commentable_type} that you also commented on. [#{AppConfig.community_name}]"
    @sent_on     = Time.now
    @body[:url]  = comment.generate_commentable_url
    @body[:user] = user
    @body[:comment] = comment
    @body[:commenter] = comment.user
  end  

  def new_forum_post_notice(user, post)
     @recipients  = "#{user.email}"
     setup_sender_info
     @subject     = "#{post.user.login} has posted in a thread you are monitoring [#{AppConfig.community_name}]."
     @sent_on     = Time.now
     @body[:url]  = "#{forum_topic_url(:forum_id => post.topic.forum, :id => post.topic, :page => post.topic.last_page)}##{post.dom_id}"
     @body[:user] = user
     @body[:post] = post
     @body[:author] = post.user
   end

  def signup_notification(user)
    setup_email(user)
    @subject    += "Please activate your new #{AppConfig.community_name} account"
    @body[:url]  = "#{APP_URL}/users/activate/#{user.activation_code}"
  end


  def post_recommendation(name, email, post, message = nil, current_user = nil)
    @recipients  = "#{email}"
    @sent_on     = Time.now
    setup_sender_info
    @subject     = "Check out this story on #{AppConfig.community_name}"
    content_type "text/html"
    @body[:name] = name  
    @body[:title]  = post.title
    @body[:post] = post
    @body[:signup_link] = (current_user ? current_user.generate_invite_url : "#{APP_URL}/signup" )
    @body[:message]  = message
    @body[:url]  = user_post_url(post.user, post)
    @body[:description] = truncate_words(post.post, 100, @body[:url] )     
  end
  
  def activation(user)
    setup_email(user)
    @subject    += "Your #{AppConfig.community_name} account has been activated!"
    @body[:url]  = "#{APP_URL}"
  end
  
  def reset_password(user)
    setup_email(user)
    @subject    += "#{AppConfig.community_name} User information"
  end

  def forgot_username(user)
    setup_email(user)
    @subject    += "#{AppConfig.community_name} User information"
  end

  
  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    setup_sender_info
    @subject     = "[#{AppConfig.community_name} registration] "
    @sent_on     = Time.now
    @body[:user] = user
  end
  
  def setup_sender_info
    @from        = "The #{AppConfig.community_name} Team <#{AppConfig.support_email}>"    
  end
  
end
