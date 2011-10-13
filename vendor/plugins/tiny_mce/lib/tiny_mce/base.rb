module TinyMCE
  # The base module we include into ActionController::Base
  module Base
    # When this module is included, extend it with the available class methods
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # The controller declaration to enable tiny_mce on certain actions.
      # Takes options hash, raw_options string, and any normal params you
      # can send to a before_filter (only, except etc)
      def uses_tiny_mce(options = {}, &block)
        if block_given?
          options = block.call
        end        
        
        configuration = TinyMCE::Configuration.new(options.delete(:options), options.delete(:raw_options))
                
        # Set instance vars in the current class
        proc = Proc.new do |c|
          configurations = c.instance_variable_get(:@tiny_mce_configurations) || []
          configurations << configuration
          c.instance_variable_set(:@tiny_mce_configurations, configurations)
          c.instance_variable_set(:@uses_tiny_mce, true)
        end

        # Run the above proc before each page load this method is declared in
        before_filter(proc, options)
      end
    end
  end
end
