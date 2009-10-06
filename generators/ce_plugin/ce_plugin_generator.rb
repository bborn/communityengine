class CePluginGenerator < PluginGenerator
  
  def initialize(runtime_args, runtime_options = {})
    super
    @plugin_path = "vendor/plugins/community_engine_#{file_name}"
  end

  def manifest
    record do |m|
      m.directory "#{plugin_path}/app"      
      m.directory "#{plugin_path}/config"
      m.directory "#{plugin_path}/db"
      m.directory "#{plugin_path}/lib"
      m.directory "#{plugin_path}/public"            
      m.directory "#{plugin_path}/tasks"
      m.directory "#{plugin_path}/test"
      
      m.template 'README', "#{plugin_path}/README"
      m.template 'init.rb', "#{plugin_path}/init.rb"
      m.template 'plugin.rb', "#{plugin_path}/lib/#{file_name}.rb"            
      m.template  'desert_routes.rb', "#{plugin_path}/config/desert_routes.rb"      
    end    
  end
  
end