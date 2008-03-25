require 'yaml'
require 'time'

module ActionController
  class AbstractResponse #:nodoc:
    attr_accessor :time_to_live
  end
  
  module Caching
    module Actions

      # All documentation is keeping DRY in the plugin's README
      
      def expire_all_actions
        return unless perform_caching
        expire_fragment(/.*\/(META|DATA)\/.*/)
      end

      def expire_one_action(options)
        expire_fragment(Regexp.new(".*/" + ActionCachePath.path_for(self, options) + ".*"))
      end
      
      def expire_action(options = {})
        return unless perform_caching
        if options[:action].is_a?(Array)
          options[:action].dup.each do |action|
            expire_one_action options.merge({ :action => action })
          end
        else
          expire_one_action options
        end
      end

      def action_fragment_key(options)
        url_for(options).split('://').last
      end

      # Override the 1.2 ActionCachePath class, works in 1.1.x too
      class ActionCachePath
        attr_reader :controller, :options
        
        class << self
          def path_for(*args, &block)
            new(*args).path
          end
        end
        
        def initialize(controller, options = {})
          @controller = controller
          @options    = options
        end

        # Override this to change behavior
        def path
          return @path if @path
          @path = @controller.send(:action_fragment_key, @options)
          add_extension!
          clean!
        end
        
        def extension
          @extension ||= extract_extension(controller.request.path)
        end
        
        private
          def clean!
            @path = @path.gsub(':', '-').gsub('?', '-')
          end
        
          def add_extension!
            @path << ".#{extension}" if extension
          end
          
          def extract_extension(file_path)
            # Don't want just what comes after the last '.' to accomodate multi part extensions
            # such as tar.gz.
            file_path[/^[^.]+\.(.+)$/, 1]
          end
      end
      
      class ActionCacheFilter #:nodoc:

        def self.fragment_key=(key_block)
          raise "fragment_key member no longer supported - use action_fragment_key on controller instead"
        end

        class CacheEntry #:nodoc:
          def initialize(headers, time_to_live = nil)
            @headers = headers.merge({ 'cookie' => [] })    # Don't send cookies for cached responses
            @expire_time = Time.now + time_to_live unless time_to_live.nil?
          end
          
          def expired?
            !expire_time.nil? && Time.now > expire_time
          end
          
          attr_reader :headers, :expire_time
        end
        
        def before(controller)
          if cache_entry = cached_entry(controller)
            if cache_entry.expired?
              remove_cache_item(controller) and return
            end
            
            if x_sendfile_enabled?(controller)
              send_using_x_sendfile(cache_entry, controller)
            else if x_accel_redirect_enabled?(controller)
                send_using_x_accel_redirect(cache_entry, controller)
              else
                if client_has_latest?(cache_entry, controller)
                  send_not_modified(controller)
                else
                  send_cached_response(cache_entry, controller)
                end              
              end
            end
                        
            controller.rendered_action_cache = true
            return false
          end
        end

        def after(controller)
          if cache_this_request?(controller)
            adjust_headers(controller)
            save_to_cache(controller)
          end
        end
        
      protected
        def adjust_headers(controller)
          if controller.response.time_to_live &&
            controller.response.headers['Cache-Control'] == 'no-cache'
            controller.response.headers['Cache-Control'] = "max-age=#{controller.response.time_to_live}"
          end
          controller.response.headers['Last-Modified'] ||= Time.now.httpdate
        end
        
        def send_cached_response(cache_entry, controller)
          controller.logger.info "Send #{body_name(controller)} by response.body"
          controller.response.headers = cache_entry.headers
          controller.response.body = fragment_body(controller)
        end
        
        def send_not_modified(controller)
          controller.logger.info "Send Not Modified"
          controller.send(:render, :text => "", :status => 304)
        end
        
        def client_has_latest?(cache_entry, controller)
          requestTime = Time.rfc2822(controller.request.env["HTTP_IF_MODIFIED_SINCE"]) rescue nil
          responseTime = Time.rfc2822(cache_entry.headers['Last-Modified']) rescue nil
          return (requestTime and responseTime and responseTime <= requestTime)
        end
        
        def remove_cache_item(controller)
          controller.expire_fragment(meta_name(controller))
          controller.expire_fragment(body_name(controller))
        end
        
        def send_using_x_sendfile(cache_entry, controller)
          filename = fragment_body_filename(controller)
          controller.logger.info "Send #{filename} by X-Sendfile"
          controller.response.headers = cache_entry.headers
          controller.response.headers["X-Sendfile"] = filename
        end

        def send_using_x_accel_redirect(cache_entry, controller)
          filename = "/cache/#{fragment_body_filename(controller)[(controller.fragment_cache_store.cache_path.length + 1)..-1]}"
          controller.logger.info "Send #{filename} by X-Accel-Redirect"
          controller.response.headers = cache_entry.headers
          controller.response.headers["X-Accel-Redirect"] = filename
        end
        
        def fragment_body_filename(controller)
          controller.fragment_cache_store.send(:real_file_path, body_name(controller))
        end

        def fragment_body(controller)
          controller.read_fragment body_name(controller)
        end

        def cache_request?(controller)
          controller.respond_to?(:cache_action?) ? controller.cache_action?(controller.action_name) : true
        end
        
        def cache_this_request?(controller)
          @actions.include?(controller.action_name.intern) && cache_request?(controller) &&
            !controller.rendered_action_cache && controller.response.headers['Status'] == '200 OK'
        end

        def cached_entry(controller)
          if @actions.include?(controller.action_name.intern) && 
            cache_request?(controller) && 
            (cache = controller.read_fragment(meta_name(controller)))
            return YAML.load(cache)
          end
          return nil
        end
                        
        def save_to_cache(controller)
          cache = CacheEntry.new(controller.response.headers, controller.response.time_to_live)
          controller.write_fragment(body_name(controller), controller.response.body)
          controller.write_fragment(meta_name(controller), YAML.dump(cache))
        end
                
        def x_sendfile_enabled?(controller)
          (controller.request.env["ENABLE_X_SENDFILE"] == "true" ||
           controller.request.env["HTTP_X_ENABLE_X_SENDFILE"] == "true") &&
            controller.fragment_cache_store.is_a?(ActionController::Caching::Fragments::UnthreadedFileStore)
        end

        def x_accel_redirect_enabled?(controller)
          controller.request.env["HTTP_ENABLE_X_ACCEL_REDIRECT"] == "true" &&
            controller.fragment_cache_store.is_a?(ActionController::Caching::Fragments::UnthreadedFileStore)
        end

        def meta_name(controller)
          "META/#{ActionCachePath.path_for(controller)}"
        end
        
        def body_name(controller)
          "DATA/#{ActionCachePath.path_for(controller)}"
        end
      end

    end
  end
end

      