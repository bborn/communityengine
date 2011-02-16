require 'rake/clean'

namespace :community_engine do   
  
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
  
  namespace :db do
    namespace :fixtures do
      desc "Load community engine fixtures"
      task :load => :environment do
        require 'active_record/fixtures'
        ActiveRecord::Base.establish_connection(Rails.env.to_sym)
        Dir.glob(File.join(Rails.root, 'vendor', 'plugins', 'community_engine','test','fixtures', '*.{yml,csv}')).each do |fixture_file|
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