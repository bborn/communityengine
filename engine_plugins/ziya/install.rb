# Installs Ziya charts artifacts to embedding app
require 'fileutils'

plugins_dir     = File.join( File.expand_path( "." ), "/vendor/plugins" )
swf_plugin_dir  = File.join( plugins_dir, 'ziya' )
artifact_dir    = File.join( swf_plugin_dir, 'artifacts' )
app_dir         = File.join( swf_plugin_dir, '../../..' )
app_public_dir  = File.join( app_dir, "public" )
charts_dir      = File.join( app_public_dir, 'charts' )

puts ">>> Copying Ziya charts to #{app_public_dir} directory..."
FileUtils.cp_r File.join( artifact_dir, 'charts' ), app_public_dir

puts ">>> Copying Ziya styles to #{charts_dir}"
FileUtils.cp_r File.join( artifact_dir, 'themes' ), charts_dir                                                    