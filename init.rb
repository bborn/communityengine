#Reload CE in development
if RAILS_ENV == 'development'
  ActiveSupport::Dependencies.load_once_paths = ActiveSupport::Dependencies.load_once_paths.select {|path| (path =~ /(community_engine)/).nil? }  
end

#Alias Desert's routing method to preserve compatibility with Engine's
Desert::Rails::RouteSet.module_eval do
  alias_method :from_plugin, :routes_from_plugin  
end

#Hack Desert to allow generating plugin migrations
Desert::Plugin.class_eval do
  def latest_migration
    migrations.last
  end
  
  # Returns the version numbers of all migrations for this plugin.
  def migrations
    migrations = Dir[migration_path+"/*.rb"]
    migrations.map { |p| File.basename(p).match(/0*(\d+)\_/)[1].to_i }.sort
  end    
end

# Fix Desert's 'current_version' which tries to order by version desc, but version is a string type column, so it breaks
# sort the rows in ruby instead to make sure we get the highest numbered version
Desert::PluginMigrations::Migrator.class_eval do
  class << self
    def current_version #:nodoc:
      result = ActiveRecord::Base.connection.select_values("SELECT version FROM #{schema_migrations_table_name} WHERE plugin_name = '#{current_plugin.name}'").map(&:to_i).sort.reverse[0]
      if result
        result
      else
        # There probably isn't an entry for this plugin in the migration info table.
        0
      end
    end
  end
end


require 'community_engine'
require 's3_cache_control'

Module.class_eval do
  def expiring_attr_reader(method_name, value)
    class_eval(<<-EOS, __FILE__, __LINE__)
      def #{method_name}
        class << self; attr_reader :#{method_name}; end
        @#{method_name} = eval(%(#{value}))
      end
    EOS
  end
end

class ActionView::Base
  def _(s)
    # just call the globalite localize method on the string
    s.localize
  end
end

module ApplicationConfiguration
  require 'ostruct'
  require 'yaml'  
  if File.exists?( File.join(RAILS_ROOT, 'config', 'application.yml') )
    file = File.join(RAILS_ROOT, 'config', 'application.yml')
    users_app_config = YAML.load_file file
  end
  default_app_config = YAML.load_file(File.join(RAILS_ROOT, 'vendor', 'plugins', 'community_engine', 'config', 'application.yml'))
  
  config_hash = (users_app_config||{}).reverse_merge!(default_app_config)

  unless defined?(AppConfig)
    ::AppConfig = OpenStruct.new config_hash
  else
    orig_hash   = AppConfig.marshal_dump
    merged_hash = config_hash.merge(orig_hash)
    
    AppConfig = OpenStruct.new merged_hash
  end
end


