namespace :community_engine do   
  
  namespace :deployment do
    # =============================================================================
    # MANUAL SETUP TASKS (WARNING: SEMI-DESTRUCTIVE TASKS)
    # =============================================================================
    desc "Setup mysql databases and permissions"
    task :mysql_setup, :roles => [:db] do 
      mysql_setup_file = render :template => <<-EOF
    CREATE DATABASE #{application}_development;
    CREATE DATABASE #{application}_test;
    CREATE DATABASE #{application}_production;
    GRANT ALL PRIVILEGES ON #{application}_development.* TO '#{database_username}'@'localhost' IDENTIFIED BY '#{database_password}';
    GRANT ALL PRIVILEGES ON #{application}_test.* TO '#{database_username}'@'localhost' IDENTIFIED BY '#{database_password}';
    GRANT ALL PRIVILEGES ON #{application}_production.* TO '#{database_username}'@'localhost' IDENTIFIED BY '#{database_password}';
    FLUSH PRIVILEGES;
    EOF
      put mysql_setup_file, "#{deploy_to}/#{shared_dir}/system/mysql_setup_file.sql"
      run "mysql -u root < #{deploy_to}/#{shared_dir}/system/mysql_setup_file.sql"
    end

  end

end