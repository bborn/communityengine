class UserNotifier < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper
  extend  ActionView::Helpers::SanitizeHelper::ClassMethods # Required for rails 2.2
  include BaseHelper
  
  default_url_options[:host] = configatron.app_host
  default :from => "#{:the_team.l(:site => configatron.community_name, :email => configatron.support_email)}"  

  def signup_invitation(email, user, message)
    setup_sender_info
    @recipients  = "#{email}"
    @subject     = "#{:would_like_you_to_join.l(:user => user.login, :site => configatron.community_name)}"
    @sent_on     = Time.now
    @user = user
    @url  = signup_by_id_url(user, user.invite_code)
    @message = message
  end

  def friendship_request(friendship)
    setup_email(friendship.friend)
    @subject     += "#{:would_like_to_be_friends_with_you_on.l(:user => friendship.user.login, :site => configatron.community_name)}"
    @url  = pending_user_friendships_url(friendship.friend)
    @requester = friendship.user
  end
  
  def friendship_accepted(friendship)
    setup_email(friendship.user) 
    @subject     += "#{:friendship_request_accepted.l}"
    @requester = friendship.user
    @friend    = friendship.friend
    @url       = user_url(friendship.friend)
  end

  def comment_notice(comment)
    setup_email(comment.recipient)
    @subject     += "#{:has_something_to_say_to_you_on.l(:user => comment.username, :site => configatron.community_name)}"
    @url  = commentable_url(comment)
    @comment = comment
    @commenter = comment.user
  end
  
  def follow_up_comment_notice(user, comment)
    setup_email(user)
    @subject     += "#{:has_commented_on_something_that_you_also_commented_on.l(:user => comment.username, :item => comment.commentable_type)}"
    @url  = commentable_url(comment)
    @comment = comment
    @commenter = comment.user
  end  

  def follow_up_comment_notice_anonymous(email, comment)
    @recipients  = "#{email}"
    setup_sender_info
    @subject     = "[#{configatron.community_name}] "
    @sent_on     = Time.now
    @subject     += "#{:has_commented_on_something_that_you_also_commented_on.l(:user => comment.username, :item => comment.commentable_type)}"
    @url  = commentable_url(comment)
    @comment = comment

    @unsubscribe_link = url_for(:controller => 'comments', :action => 'unsubscribe', :comment_id => comment.id, :token => comment.token_for(email), :email => email)
  end

  def new_forum_post_notice(user, post)
     setup_email(user)
     @subject     += "#{:has_posted_in_a_thread_you_are_monitoring.l(:user => post.username)}"
     @url  = "#{forum_topic_url(:forum_id => post.topic.forum, :id => post.topic, :page => post.topic.last_page)}##{post.dom_id}"
     @post = post
     @author = post.username
   end

  def signup_notification(user)
    setup_email(user)
    @subject    += "#{:please_activate_your_new_account.l(:site => configatron.community_name)}"
    @url  = "#{home_url}users/activate/#{user.activation_code}"
  end
  
  def message_notification(message)
    setup_email(message.recipient)
    @subject     += "#{:sent_you_a_private_message.l(:user => message.sender.login)}"
    @message = message
  end


  def post_recommendation(name, email, post, message = nil, current_user = nil)
    @recipients  = "#{email}"
    @sent_on     = Time.now
    setup_sender_info
    @subject     = "#{:check_out_this_story_on.l(:site => configatron.community_name)}"
    content_type "text/plain"
    @name = name  
    @title  = post.title
    @post = post
    @signup_link = (current_user ?  signup_by_id_url(current_user, current_user.invite_code) : signup_url )
    @message  = message
    @url  = user_post_url(post.user, post)
    @description = truncate_words(post.post, 100, @url )     
  end
  
  def activation(user)
    setup_email(user)
    @subject    += "#{:your_account_has_been_activated.l(:site => configatron.community_name)}"
    @url  = home_url
  end
  
  def password_reset_instructions(user)
    setup_email(user)
    @subject    += "#{:user_information.l(:site => AppConfig.community_name)}"
    sent_on       Time.now
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)    
    @subject    += "#{:user_information.l(:site => configatron.community_name)}"
  end

  def forgot_username(user)
    setup_email(user)
    @subject    += "#{:user_information.l(:site => configatron.community_name)}"
  end

  
  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    setup_sender_info
    @subject     = "[#{configatron.community_name}] "
    @sent_on     = Time.now
    @user = user
  end
  
  def setup_sender_info
    headers "Reply-to" => "#{configatron.support_email}"
    @content_type = "text/plain"           
  end
  
end
