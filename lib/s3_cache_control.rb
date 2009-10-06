begin
  require 'aws/s3'
  
  # Adds expiration headers to all stored S3 objects through duck-punching.
  # Based on Keaka Jackson's original work.
  #
  module AWS::S3
    class S3Object
      class << self
        MAX_AGE = 8.years
        def store_with_cache_control(key, data, bucket = nil, options = {})
          if (options['Cache-Control'].blank?)
            options[:cache_control] = "max-age=#{MAX_AGE.to_i}"
            options[:expires]       = MAX_AGE.from_now.httpdate
          end
          store_without_cache_control(key, data, bucket, options)
        end
        alias_method_chain :store, :cache_control
      end
    end
  end  
  
rescue LoadError
  # silently fail here
end