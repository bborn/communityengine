require File.dirname(__FILE__) + '/parser'
require File.dirname(__FILE__) + '/restrictions'

module ActiveRecord::Validations::DateTime
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end
  
  mattr_accessor :us_date_format
  us_date_format = false
  
  module ClassMethods
    %w{date time date_time}.each do |validator|
      class_eval <<-END
        def validates_#{validator}(*attr_names)
          configuration = { :message        => "is an invalid #{validator.humanize.downcase}",
                            :before_message => "must be before %s",
                            :after_message  => "must be after %s",
                            :on => :save }
          
          configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
          configuration.assert_valid_keys :message, :before_message, :after_message, :before, :after, :if, :on, :allow_nil
          
          # We must remove this from the configuration that is passed to validates_each because
          # we want to have our own definition of nil that uses the before_type_cast value
          allow_nil = configuration.delete(:allow_nil)
          
          before_restrictions, after_restrictions = Restrictions.relative_#{validator}_restrictions(configuration)
          
          validates_each(attr_names, configuration) do |record, attr_name, value|
            value_to_parse = record.send("\#{attr_name}_before_type_cast")
            
            if value_to_parse.blank? && allow_nil
              record.send("\#{attr_name}=", nil)
            else
              value_to_parse = Parser.parse_date_time(value_to_parse) rescue value_to_parse
              
              begin
                result = Parser.parse_#{validator}(value_to_parse)
                
                if failed_restriction = Restrictions.#{validator}_before(result, record, before_restrictions)
                  record.errors.add(attr_name, configuration[:before_message] % failed_restriction)
                end
                
                if failed_restriction = Restrictions.#{validator}_after(result, record, after_restrictions)
                  record.errors.add(attr_name, configuration[:after_message] % failed_restriction)
                end
                
                record.send("\#{attr_name}=", result) unless record.errors.on(attr_name)
              rescue Parser::#{validator.camelize}ParseError
                record.errors.add(attr_name, configuration[:message])
              end
            end
          end
        end
      END
    end
  end
  
  module InstanceMethods
    def execute_callstack_for_multiparameter_attributes_with_temporal_error_handling(callstack)
      errors = []
      callstack.each do |name, values|
        klass = (self.class.reflect_on_aggregation(name.to_sym) || column_for_attribute(name)).klass
        
        if values.empty?
          send("#{name}=", nil)
        else
          if [Date, Time].include?(klass)
            values = values.map(&:to_s)
            date_string = [values.shift.rjust(4, "0"), *values.slice!(0, 2).map { |s| s.rjust(2, "0") }].join('-')
            
            if klass == Date
              send("#{name}=", date_string)
            elsif klass == Time
              time_string = values.map { |s| s.rjust(2, "0") }.join(':')
              send("#{name}=", "#{date_string} #{time_string}")
            end
          else
            begin
              send(name + "=", Time == klass ? klass.local(*values) : klass.new(*values))
            rescue => ex
              errors << ActiveRecord::AttributeAssignmentError.new("error on assignment #{values.inspect} to #{name}", ex, name)
            end
          end
        end
      end
      unless errors.empty?
        raise ActiveRecord::MultiparameterAssignmentErrors.new(errors), "#{errors.size} error(s) on assignment of multiparameter attributes"
      end
    end
  end
end

class ActiveRecord::Base
  include ActiveRecord::Validations::DateTime
  
  alias_method :execute_callstack_for_multiparameter_attributes_without_temporal_error_handling, :execute_callstack_for_multiparameter_attributes
  alias_method :execute_callstack_for_multiparameter_attributes, :execute_callstack_for_multiparameter_attributes_with_temporal_error_handling
end
