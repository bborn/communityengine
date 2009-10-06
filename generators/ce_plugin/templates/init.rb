config.after_initialize do
  if RAILS_ENV == 'development'
    ActiveSupport::Dependencies.load_once_paths = ActiveSupport::Dependencies.load_once_paths.select {|path| (path =~ /(community_engine_<%= file_name %>)/).nil? }  
  end
end 

require_plugin 'community_engine'
config.plugin_paths += ["#{RAILS_ROOT}/vendor/plugins/community_engine_<%= file_name %>/plugins"]