namespace :community_engine do   
    
  desc "Generate deploy.rb"
  task :generate_deploy_script => :environment do
    require 'erb'
    require 'yaml'
        
    public_hostname = ENV["hostname"]                
    application = ENV["application"]
    repository = ENV["repo"]
    db_user = ENV["db_user"]    
    db_pass = ENV["db_pass"]        
    
    abort('Missing variables') unless application && repository && db_user && db_pass && public_hostname
    
    deploy_templates_dir = "#{File.dirname(__FILE__)}/../sample_files/deployment_templates"
    deploy_file = ERB.new(File.read("#{deploy_templates_dir}/deploy.erb"), nil, '>').result(binding)    

    File.open("#{RAILS_ROOT}/config/deploy.rb", 'w+') {|f| 
      f.write(deploy_file) 
    }

    `mkdir -p #{RAILS_ROOT}/config/config_templates`
    `cp -r #{deploy_templates_dir}/* '#{RAILS_ROOT}/config/config_templates'`
    `rm #{RAILS_ROOT}/config/config_templates/deploy.erb`
  end
  

end