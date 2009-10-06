# Copyright (c) 2005 Trevor Squires
# Released under the MIT License.  See the LICENSE file for more details.

module ActiveRecord
  module VirtualEnumerations # :nodoc:
    class << self       
      def define
        raise ArgumentError, "#{self.name}: must pass a block to define()" unless block_given?
        config = ActiveRecord::VirtualEnumerations::Config.new
        yield config
        @config = config # we only overwrite config if no exceptions were thrown
      end
      
      def synthesize_if_defined(const)
        options = @config[const]
        return nil unless options
        class_def = <<-end_eval
          class #{const} < #{options[:extends]}
            acts_as_enumerated  :conditions => #{options[:conditions].inspect},
                                :order => #{options[:order].inspect},
                                :on_lookup_failure => #{options[:on_lookup_failure].inspect}
            set_table_name(#{options[:table_name].inspect}) unless #{options[:table_name].nil?}
          end          
        end_eval
        eval(class_def, TOPLEVEL_BINDING)
        rval = const_get(const)
        if options[:post_synth_block]
          rval.class_eval(&options[:post_synth_block])
        end
        return rval
      end      
    end
    
    class Config
      def initialize
        @enumeration_defs = {}
      end
      
      def define(arg, options = {}, &synth_block)
        (arg.is_a?(Array) ? arg : [arg]).each do |class_name|
          camel_name = class_name.to_s.camelize 
          raise ArgumentError, "ActiveRecord::VirtualEnumerations.define - invalid class_name argument (#{class_name.inspect})" if camel_name.blank?
          raise ArgumentError, "ActiveRecord::VirtualEnumerations.define - class_name already defined (#{camel_name})" if @enumeration_defs[camel_name.to_sym]
          options.assert_valid_keys(:table_name, :extends, :conditions, :order, :on_lookup_failure)
          enum_def = options.clone
          enum_def[:extends] ||= "ActiveRecord::Base"
          enum_def[:post_synth_block] = synth_block
          @enumeration_defs[camel_name.to_sym] = enum_def   
        end
      end
      
      def [](arg)
        @enumeration_defs[arg]
      end            
    end #class Config
  end #module VirtualEnumerations
end #module ActiveRecord

class Module # :nodoc:
  alias_method :enumerations_original_const_missing, :const_missing
  def const_missing(const_id)
    # let rails have a go at loading it
    enumerations_original_const_missing(const_id)
  rescue NameError
    # now it's our turn
    ActiveRecord::VirtualEnumerations.synthesize_if_defined(const_id) or raise
  end
end
