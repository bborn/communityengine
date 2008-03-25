# Copyright (c) 2005 Trevor Squires
# Released under the MIT License.  See the LICENSE file for more details.

module ActiveRecord
  module Aggregations # :nodoc:
    module HasEnumerated # :nodoc:
      def self.append_features(base)
        super      
        base.extend(MacroMethods)
      end

      module MacroMethods                      
        def has_enumerated(part_id, options = {})
          options.assert_valid_keys(:class_name, :foreign_key, :on_lookup_failure)

          name        = part_id.id2name
          class_name  = (options[:class_name] || name).to_s.camelize
          foreign_key = (options[:foreign_key] || "#{name}_id").to_s             
          failure     = options[:on_lookup_failure]

          module_eval <<-end_eval
            def #{name}
              rval = #{class_name}.lookup_id(self.#{foreign_key})
              if rval.nil? && #{!failure.nil?}
                return self.send(#{failure.inspect}, :read, #{name.inspect}, #{foreign_key.inspect}, #{class_name.inspect}, self.#{foreign_key})
              end
              return rval
            end         

            def #{name}=(arg)                         
              case arg
              when #{class_name}
                val = #{class_name}.lookup_id(arg.id)
              when String
                val = #{class_name}.lookup_name(arg)
              when Symbol
                val = #{class_name}.lookup_name(arg.id2name)
              when Fixnum
                val = #{class_name}.lookup_id(arg)
              when nil
                val = nil
              else     
                raise TypeError, "#{self.name}: #{name}= argument must be a #{class_name}, String, Symbol or Fixnum but got a: \#{arg.class.name}"            
              end

              if val.nil? 
                if #{failure.nil?}
                  raise ArgumentError, "#{self.name}: #{name}= can't assign a #{class_name} for a value of (\#{arg.inspect})"
                end
                self.send(#{failure.inspect}, :write, #{name.inspect}, #{foreign_key.inspect}, #{class_name.inspect}, arg)
              else
                self.#{foreign_key} = val.id
              end
            end
          end_eval
        end
      end
    end
  end
end
