# #load everything in /engine_config/initializers
# # initializers in your root 'initializers' directory will take precedence if they have the same file name
# 
# Dir["#{Rails.root}/vendor/plugins/community_engine/config/initializers/**/*.rb"].each do |initializer| 
#   load(initializer) unless File.exists?("#{Rails.root}/config/initializers/#{File.basename(initializer)}")
# end
# 
# CommunityEngine.check_for_pending_migrations
# 
# if configatron.theme
#   theme_view_path = "#{Rails.root}/themes/#{configatron.theme}/views"
#   ActionController::Base.view_paths = ActionController::Base.view_paths.dup.unshift(theme_view_path)
# end
# 
# 
# EnginesHelper::Assets.propagate if EnginesHelper.autoload_assets
#  
# # # If the app is using Haml/Sass, propagate sass directories too
# # EnginesHelper::Assets.update_sass_directories
# 
