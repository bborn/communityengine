# Utility methods
def say(message)
  puts " [CE SETUP] #{message} \n "
end

def checkout_ce_branch(branch)
  inside 'vendor/plugins/community_engine' do
    say "Checking out the #{branch} branch"
    run "git checkout --track -b #{branch} origin/#{branch}"
  end  
end

def modify_environment_files
  in_root do
    say "Modifying your environment.rb and environments files to work with CE"
    sentinel        = "require File.join(File.dirname(__FILE__), 'boot')"
    desert_require  = "require 'desert'"
    gsub_file 'config/environment.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
      "#{match}\n #{desert_require}\n"
    end    
    
    ce_plugins_config = <<EOF
config.plugins = [:community_engine, :white_list, :all]
config.plugin_paths += ["\#{RAILS_ROOT}/vendor/plugins/community_engine/plugins"]
EOF
    environment ce_plugins_config 

    ce_boot_line = "\n require \"\#{RAILS_ROOT}/vendor/plugins/community_engine/config/boot.rb\""
    append_file 'config/environment.rb', ce_boot_line

    say "Modifying environment files ..."
    ['development', 'test'].each do |env|
      environment "\nAPP_URL = \"http://localhost:3000\"", :env => env
    end
    app_url = ask("Please enter the url where you plan to deploy this app (use 'example.com' for now if you don't know yet):")
    environment "\nAPP_URL = \"http://#{app_url}\"", :env => 'production'
  end
end

def add_application_yml(name)
  file("config/application.yml") do
    "community_name: #{name}"
  end  
end


# CommunityEngine Setup
ce_git_repo = "git://github.com/bborn/communityengine.git"
app_name    = ask("Please enter the application's name: ")
  
# Delete unnecessary files
run "rm public/index.html"
 
# Set up git repository
git :init
git :add => '.'
    
# Set up .gitignore files
  run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
  run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore}
  file '.gitignore', <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
END

# Install all gems
gem 'desert', :lib => 'desert'
gem 'rmagick', :lib => 'RMagick'  
gem 'hpricot', :lib => 'hpricot'    
gem 'htmlentities', :lib => 'htmlentities'      
gem 'haml', :lib => 'haml'        
gem "aws-s3", :lib => "aws/s3" 
gem 'calendar_date_select'
gem 'ri_cal'
gem 'authlogic'
gem 'searchlogic'
gem 'akismet'

rake('gems:install', :sudo => true)


plugin 'community_engine', :git => ce_git_repo, :submodule => true

# Initialize submodules
git :submodule => "init" 
git :submodule => "update"   
checkout_ce_branch('edge')

# Add CE routes 
route "map.routes_from_plugin :community_engine"
 
modify_environment_files
add_application_yml(app_name)

generate :plugin_migration

rake('db:create:all')
rake('db:migrate')

capify!
  
# Commit all work so far to the repository
git :add => '.'
git :commit => "-a -m 'Initial commit'"

# Success!
puts "SUCCESS!"
puts "Next, you should probably run `rake test` and `rake community_engine:test` and make sure all tests pass. "
