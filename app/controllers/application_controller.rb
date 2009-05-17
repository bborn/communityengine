class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # helper_method :commentable_url
  # 
  # def commentable_url(comment)
  #   if comment.recipient
  #     if comment.commentable_type != "User"
  #       polymorphic_url([comment.recipient, comment.commentable])+"#comment_#{comment.id}"
  #     else
  #       user_url(comment.recipient)+"#comment_#{comment.id}"
  #     end
  #   else
  #     polymorphic_url(comment.commentable)+"#comment_#{comment.id}"      
  #   end
  # end  
end
