# CommunityEngine
module CommunityEngine
  module ActiveRecordExtensions
    def prepare_options_for_attachment_fu(options)
      attachment_fu_options = options.symbolize_keys.merge({:storage => options['storage'].to_sym, 
          :max_size => options['max_size'].to_i.megabytes})  
    end      
  end  
  
  class << self

    def check_for_pending_migrations
      newest_ce_migration = Engines.plugins[:community_engine].latest_migration
      current_ce_version  = guess_current_ce_version

      pending = newest_ce_migration - current_ce_version
      if pending > 0
        puts "---"        
        puts "[COMMUNITY ENGINE] You have #{pending} pending CommunityEngine migrations:"
        puts "CE is at #{newest_ce_migration}, but you have only migrated it to #{current_ce_version}"
        puts "Please run 'script/generate plugin_migration' AND 'rake db:migrate' before continuing, or you will experience errors."
        puts "---"
      end      
    end
    
    def guess_current_ce_version
      # DUMB: checks your db/migrate and parses out the last CE migration to find out which version you're at      
      last_version =  Dir["#{RAILS_ROOT}/db/migrate/[0-9]*_community_engine_*.rb"].sort.last
      if last_version
        last_version[/.*_community_engine_to_version_(\d+)/, 1].to_i
      else
        0
      end
    end
    
  end
  
end

ActiveRecord::Base.send(:extend, CommunityEngine::ActiveRecordExtensions)