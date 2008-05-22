namespace :community_engine do   

  desc 'Install Community Engine for the first time'
  task :install => [:check_required_gems] do
        
    Rake::Task["community_engine:generate_plugin_migrations"].invoke
    #check for engines plugin
  end
  
  desc 'Check if the required gems are present'
  task :check_required_gems do
    #check if we have the required gems
    installed_gems = `gem list --no-details --no-versions`.split("\n")
    required_gems = %w(rmagick hpricot mime-types htmlentities RedCloth rake mysql)
    missing_gems = required_gems-installed_gems
    
    if missing_gems.any?
      raise "CommunityEngine installation can't continue because you are missing these required gems: \n  - #{missing_gems.join("\n- ")}"
    end
  end
  
  desc 'Generate CommunityEngine plugin migrations'
  task :generate_plugin_migrations do
    `./script/generate plugin_migration community_engine`
  end
  
end


