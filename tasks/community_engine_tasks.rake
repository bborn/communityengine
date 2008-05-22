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
    
  desc 'Move the community engine assets to application public directory'
  task :mirror_public_assets => :environment do
    # actually, no need to do anything here, the mere act of running rake mirrors the plugin assets for everything
    # Engines::Assets.mirror_files_for(Rails.plugins[:community_engine])
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

  desc 'load a bunch of test users RAILS_ENV= NUM_USERS='
  task :load_test_users => [:environment]  do
    ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
    num = ENV['NUM_USERS'] || 10000
    puts "-- LOADING NUM_USERS: #{num}"
    (0..num.to_i).each do |n|
       printf "#{n}." if (n.remainder(100) == 0)
       u= User.new(
         :login=>"#{Time.now.to_i}.#{n}",
         :password=>"standard",
         :password_confirmation=>"standard",
         :activated_at => Time.now.to_s(:db)
       )

       u.email = "#{Time.now.to_i}.#{n}@example.com"
       u.save!
    end
    puts "" 
  end

  desc 'load a bunch of test posts RAILS_ENV= NUM_USERS='
  task :load_test_posts=>[:environment]  do
    ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
    users = User.find(:all, :limit => 10)
    categories = Category.find(:all)

    num = ENV['NUM_POSTS'] || 20000
    puts "-- LOADING NUM_POSTS: #{num}"

    (0..num.to_i).each do |n|
       printf "#{n}." if (n.remainder(1000) == 0)

       p = Post.new(
       :title=>"This post is Awesome! #{n}",
       :raw_post=> "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor      incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse            cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. body",
       :post=> "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor      incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse            cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. body",
       :user => users[rand(users.size-1)],
       :category => categories[rand(categories.size-1)]
          )
          p.save!
    end
    puts "" 
  end

  desc 'load a bunch of test posts RAILS_ENV= NUM_USERS='
  task :load_test_post_comments=>[:environment]  do
    ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
    users = User.find(:all)
    posts = Post.find(:all)

    num = ENV['NUM_COMMENTS'] || 40000
    puts "-- LOADING NUM_COMMENTS: #{num}"

    (0..num.to_i).each do |n|
       printf "#{n}." if (n.remainder(1000) == 0)

       commentable = posts[rand(posts.size-1)]
       user = users[rand(users.size-1)]

       c = Comment.new(
       :comment=> "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor      incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation Duis aute irure dolor in reprehenderit cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat ",
       :commentable => commentable,
       :commentable_type => commentable.class.to_s,
       :recipient => commentable.owner,
       :user => user
          )
          c.save!
    end
    puts "" 
  end

end