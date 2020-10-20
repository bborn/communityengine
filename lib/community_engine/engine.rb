require "community_engine"
require 'rails/all'

module CommunityEngine
  class Engine < Rails::Engine
    engine_name "community_engine"

    config.railties_order = [ CommunityEngine::Engine, :main_app, :all]


    initializer engine_name do |app|
      require root.join('config','application_config.rb')
      require app.root.join('config','application_config.rb')

      ActiveAdmin.application.load_paths += Dir[File.dirname(__FILE__) + '/admin']
    end

    initializer "#{engine_name}.initializers", :before => :load_config_initializers do
      Dir["#{root}/config/initializers/**/*.rb"].each do |initializer|
        load(initializer) unless File.exists?("#{root.to_s}/config/initializers/#{File.basename(initializer)}")
      end
    end

    # initializer "#{engine_name}.rails4", :after => "active_record.observer" do
    #   ActiveSupport.on_load(:action_controller) do
    #     ActionController::Base.send :include, ActionController::Caching::Pages
    #     ActionController::Base.send :include, ActionController::Caching::Actions
    #   end
    # end

    # initializer "#{engine_name}.sweeper.rails4", :after => "action_controller.caching.sweepers" do
    #   ActiveSupport.on_load(:action_controller) do
    #     ActionController::Caching::Sweeper.send(:include, ActiveSupport::Configurable)
    #     ActionController::Caching::Sweeper.send(:include, ActionController::Caching)
    #     ActionController::Caching::Sweeper.send(:include, ActionController::Caching::Pages)
    #     ActionController::Caching::Sweeper.send(:include, ActionController::Caching::Actions)
    #   end
    # end

    initializer "#{engine_name}.rakismet_config", :before => "rakismet.setup" do |app|
      if configatron.has_key?(:akismet_key)
        app.config.rakismet.key  = configatron.akismet_key
        app.config.rakismet.url  = configatron.app_host
      end
    end

  end
end

