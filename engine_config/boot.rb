#load everything in /engine_config/initializers
Dir["#{RAILS_ROOT}/vendor/plugins/community_engine/engine_config/initializers/**/*.rb"].each do |initializer| 
  load(initializer) 
end

CommunityEngine.check_for_pending_migrations

if AppConfig.theme
  theme_view_path = "#{RAILS_ROOT}/themes/#{AppConfig.theme}/views"
  ActionController::Base.view_paths = ActionController::Base.view_paths.dup.unshift(theme_view_path)
end
