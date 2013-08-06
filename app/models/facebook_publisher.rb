class FacebookPublisher
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper
  extend  ActionView::Helpers::SanitizeHelper::ClassMethods
  

  def self.connected(user)
    text = "I joined #{configatron.community_name}."    
    if user.friends_ids.any?
      text += " There are #{pluralize user.friends_ids.size,'friends'} in my network."
    else
      text += " Want to join me?"
    end

    href = home_url

    user.graph.put_wall_post(text, :link => href, :name => configatron.community_name )
  end
  
  def self.comment_created_hash(comment, url)
    {
      :method => 'feed',
      :link => url,
      :name => "I left a comment on #{configatron.community_name}",
      :description => comment
    }.to_json
  end
    
  def self.blog_post_created_hash(post)
    hash = {
      :method => "feed",
      :name => post.title,
      :description => strip_tags(post.post),
      :link => user_post_url(post.user, post, :host => default_host),
    }
    hash[:picture] = post.first_image_in_body unless post.first_image_in_body.nil?
    hash.to_json
  end
    
  def self.default_host
    configatron.app_host
  end
    
end