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

end