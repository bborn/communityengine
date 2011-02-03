
# #reload CE in development
# config.after_initialize do
#   if RAILS_ENV == 'development'
#     config.autoload_paths += %W(#{config.root}/lib/community_engine)    
#   end
# end 
# 
# require 'community_engine'
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
# module ApplicationConfiguration
#   require 'ostruct'
#   require 'yaml'  
#   if File.exists?( Rails.root.join('application.yml') )
#     file = Rails.root.join('application.yml')
#     users_app_config = YAML.load_file file
#   end
#   default_app_config = YAML.load_file(File.join(Rails.root, 'vendor', 'plugins', 'community_engine', 'config', 'application.yml'))
#   
#   config_hash = (users_app_config||{}).reverse_merge!(default_app_config)
# 
#   unless defined?(configatron)
#     ::configatron = OpenStruct.new config_hash
#   else
#     orig_hash   = configatron.marshal_dump
#     merged_hash = config_hash.merge(orig_hash)
#     
#     configatron = OpenStruct.new merged_hash
#   end
# end
# 
# 
