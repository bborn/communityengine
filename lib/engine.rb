
require 'rails/all'
require "community_engine"

module CommunityEngine
  class Engine < Rails::Engine
  
    config.autoload_paths << File.expand_path("../plugins/", __FILE__)    
    config.mount_at = '/'
  
    initializer 'community_engine' do |app|
      
      raise config.inspect
      configatron.configure_from_yaml(root.join('config','application.yml'))
      configatron.configure_from_yaml(app.root.join('config','application.yml'))
	    app.plugin_paths += ["#{Rails.root}/vendor/plugins/community_engine/plugins"]      
      puts configatron.community_name
      puts configatron.community_tagline
    end

    # require 's3_cache_control'
    # 
    # Module.class_eval do
    #   def expiring_attr_reader(method_name, value)
    #     class_eval(<<-EOS, __FILE__, __LINE__)
    #       def #{method_name}
    #         class << self; attr_reader :#{method_name}; end
    #         @#{method_name} = eval(%(#{value}))
    #       end
    #     EOS
    #   end
    # end
    # 
    # class ActionView::Base
    #   def _(s)
    #     # just call the globalite localize method on the string
    #     s.localize
    #   end
    # end
    # 



    
    
    
  end
end