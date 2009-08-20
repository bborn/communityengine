class ActivityMigrationGenerator < Rails::Generator::Base

  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate', :assigns => {
        :migration_name => "CreateActivitiesTable"
      }, :migration_file_name => "create_activities_table"
    end
  end

end
