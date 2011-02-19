require "community_engine"
require 'rails/all'

module CommunityEngine
  class Engine < Rails::Engine
    engine_name "community_engine"

    initializer engine_name do |app|
      configatron.configure_from_yaml(root.join('config','application.yml'))
      configatron.configure_from_yaml(app.root.join('config','application.yml'))      
    end
    
    ActiveSupport.on_load(:after_initialize) do
      Dir["#{root}/config/initializers/**/*.rb"].each do |initializer| 
        load(initializer) unless File.exists?("#{root.to_s}/config/initializers/#{File.basename(initializer)}")
      end      
      require 'paperclip_processors/cropper'
    end
     
  end
end