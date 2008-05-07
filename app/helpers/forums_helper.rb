module ForumsHelper
  
  # used to know if a topic has changed since we read it last
  def recent_topic_activity(topic)
    return false if not logged_in?
    return false unless last_active || session[:topics]
    
    return topic.replied_at > (last_active || session[:topics][topic.id])
  end 
  
  # used to know if a forum has changed since we read it last
  def recent_forum_activity(forum)
    return false unless logged_in? && forum.topics.first
    return false unless last_active || session[:forums]
     
    return forum.recent_topics.first.replied_at > (last_active || session[:forums][forum.id])
  end
  
  def icon_and_color_and_post_for(topic)
    icon = "comment"
    color = ""
    post = ''
    if topic.locked?
      icon = "lock" 
      post = ", this topic is locked."
      color = "darkgrey"
    end  
    [icon, color, post  ]
  end
  
end
