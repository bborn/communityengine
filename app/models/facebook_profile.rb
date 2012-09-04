module FacebookProfile
  def self.included(base)
    base.class_eval do
      include InstanceMethods
    end
  end
  
  module InstanceMethods
    
    def fb_friend_ids
      graph.get_connections('/me', 'friends').map{|h| h['id'].to_i}      
    end
    
    def fb_friends_with?(user)
      fb_friend_ids.include?(user.profile[:id])
    end
    
    def graph
      @graph ||= Koala::Facebook::API.new(facebook_authorization.token)
    end
        
    def facebook?
      facebook_authorization
    end    
    
    def facebook_authorization
      self.authorizations.where(:provider => "facebook").first
    end
    
  end
              
end