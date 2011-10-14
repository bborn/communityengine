module TwitterProfile
  def self.included(base)
    base.class_eval do
      include InstanceMethods
    end
  end
  
  module InstanceMethods
        
    def twitter?
      twitter_authorization
    end    
    
    def twitter_authorization
      self.authorizations.where(:provider => "twitter").first
    end
    
  end
              
end