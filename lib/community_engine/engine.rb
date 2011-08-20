require "community_engine"
require 'rails/all'
require 'community_engine/util/version'

module CommunityEngine
  class Engine < Rails::Engine
    engine_name "community_engine"

    initializer engine_name do |app|
      configatron.configure_from_yaml(root.join('config','application.yml'))
      configatron.configure_from_yaml(app.root.join('config','application.yml'))      
    end
    
    initializer "#{engine_name}.load_middleware", :after => :load_config_initializers do
      if configatron.auth_providers
        configatron.protect(:auth_providers)
        configatron.auth_providers.to_hash.each do |name, hash|
          provider = "::OmniAuth::Strategies::#{name.to_s.classify}".constantize
          config.app_middleware.use provider, hash[:key], hash[:secret]          
        end
      end
    end
    
    
    ActiveSupport.on_load(:after_initialize) do
      Dir["#{root}/config/initializers/**/*.rb"].each do |initializer| 
        load(initializer) unless File.exists?("#{root.to_s}/config/initializers/#{File.basename(initializer)}")
      end      
      require 'paperclip_processors/cropper'
    end
     
  end
end