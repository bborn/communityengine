require 'rake/clean'

namespace :db do
  namespace :tables do
    desc 'Blow away all your database tables.' 
    task :drop => :environment do 
      ActiveRecord::Base.establish_connection 
      ActiveRecord::Base.connection.tables.each do |table_name| 
        # truncate resets the auto_increment counters
        ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name}") 
        ActiveRecord::Base.connection.execute("DROP TABLE #{table_name}") 
      end 
    end
  end
end

namespace :community_engine do   
  
  desc 'Mirror public assets'
  task :mirror_assets => :environment do
    #nothing
  end
  
  desc "Create user with admin role."
  task :create_admin do
    Rake::Task['environment'].invoke
    require File.join(RAILS_ROOT, 'vendor', 'plugins', 'community_engine', 'db', 'sample', 'users.rb')
  end

  desc  'Assign admin role to user. Usage: rake community_engine:make_admin email=admin@foo.com'
  task :make_admin => :environment do
    email = ENV["email"]
    user = User.find_by_email(email)
    if user
      user.role = Role[:admin]
      user.save!
      puts "#{user.login} (#{user.email}) was made into an admin."
    else
      puts "There is no user with the e-mail '#{email}'."
    end
  end
  
  desc 'Test the community_engine plugin.'
  Rake::TestTask.new(:test) do |t|         
    t.libs << 'lib'
    t.pattern = 'vendor/plugins/community_engine/test/**/*_test.rb'
    t.verbose = true    
  end
  Rake::Task['community_engine:test'].comment = "Run the community_engine plugin tests."
  
  namespace :test do
    # output directory - removed with "rake clobber"
    CLOBBER.include("coverage")
    # RCOV command, run as though from the commandline.  Amend as required or perhaps move to config/environment.rb?
    RCOV = "rcov"
    OUTPUT_DIR = "../../../coverage/community_engine"
    
    desc "generate a coverage report in coverage/communuity_engine. NOTE: you must have rcov installed for this to work!"
    task :rcov  => [:clobber_rcov] do
      params = String.new      
      if ENV['RCOV_PARAMS']
        params << ENV['RCOV_PARAMS']
      end
      # rake test:units:rcov SHOW_ONLY=models,controllers,lib,helpers
      # rake test:units:rcov SHOW_ONLY=m,c,l,h
      if ENV['SHOW_ONLY']
        show_only = ENV['SHOW_ONLY'].to_s.split(',').map{|x|x.strip}
        if show_only.any?
          reg_exp = []
          for show_type in show_only
            reg_exp << case show_type
                       when 'm', 'models' : 'app\/models'
                       when 'c', 'controllers' : 'app\/controllers'
                       when 'h', 'helpers' : 'app\/helpers'
                       when 'l', 'lib' : 'lib'
                       else
                         show_type
                       end
          end
          reg_exp.map!{ |m| "(#{m})" }
          params << " --exclude \"^(?!#{reg_exp.join('|')})\""
        end
      end
      
      sh "cd vendor/plugins/community_engine;#{RCOV} --rails -T -Ilib:test --output #{OUTPUT_DIR} test/all_tests.rb #{params}"
    end
    
    # Add a task to clean up after ourselves
    desc "Remove Rcov reports for community_engine tests"
    task :clobber_rcov do |t|
      rm_r OUTPUT_DIR, :force => true
    end
    
  end
  
  desc 'When upgrading to threaded messages, add thread to existing ones'
  task :add_threads_to_existing_messages => :environment do
    Message.all.each do |message|
      message.update_message_threads
      message.message_threads.update_all(["updated_at = ?", message.created_at])      
    end
  end

  namespace :db do
    namespace :fixtures do
      desc "Load community engine fixtures"
      task :load => :environment do
        require 'active_record/fixtures'
        ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
        Dir.glob(File.join(RAILS_ROOT, 'vendor', 'plugins', 'community_engine','test','fixtures', '*.{yml,csv}')).each do |fixture_file|
          Fixtures.create_fixtures('vendor/plugins/community_engine/test/fixtures', File.basename(fixture_file, '.*'))
        end
      end
    end
  end
  
  namespace :db do
    namespace :migrate do 
      
      desc 'For CE coming from version < 1.0.1 that stored plugin migration info in the normal Rails schema_migrations table. Move that info back into the plugin_schema_migrations table.'
      task :upgrade_desert_plugin_migrations => :environment do
        plugin_migration_table = Desert::PluginMigrations::Migrator.schema_migrations_table_name
        schema_migration_table = ActiveRecord::Migrator.schema_migrations_table_name
        
        unless ActiveRecord::Base.connection.table_exists?(plugin_migration_table)
          ActiveRecord::Migration.create_table(plugin_migration_table, :id => false) do |schema_migrations_table|
            schema_migrations_table.column :version, :string, :null => false
            schema_migrations_table.column :plugin_name, :string, :null => false            
          end
        end

        def insert_new_version(plugin_name, version, table)
          # Check if the row already exists for some reason - maybe run this task more than once.
          return if ActiveRecord::Base.connection.select_rows("SELECT * FROM #{table} WHERE version = #{version} AND plugin_name = '#{plugin_name}'").size > 0

          puts "Inserting new version #{version} for plugin #{plugin_name} in #{table}."
          ActiveRecord::Base.connection.insert("INSERT INTO #{table} (plugin_name, version) VALUES ('#{plugin_name}', #{version.to_i})")
        end
        
        def remove_old_version(plugin_name, version, table)
          puts "Removing old version #{version} for plugin #{plugin_name} in #{table}."          
          ActiveRecord::Base.connection.execute("DELETE FROM #{table} WHERE version = '#{version}-#{plugin_name}'")
        end

        existing_migrations = ActiveRecord::Base.connection.select_rows("SELECT * FROM #{schema_migration_table}").uniq
        migrations = {}
        existing_migrations.flatten.each do |m|
          plugin_version, plugin_name = m.split('-')
          next if plugin_name.blank?
          migrations[plugin_name] ||= []
          migrations[plugin_name] << plugin_version
        end
        
        migrations.each do |plugin_name, versions|
          versions.each do |version|
            insert_new_version(plugin_name, version, plugin_migration_table)
            remove_old_version(plugin_name, version, schema_migration_table)
          end
        end

      end
    end
  end

end
