module ActiveRecord
  module Validations
    module DateTime
      module Restrictions
        class RestrictionError< StandardError #:nodoc:
        end
        
        class << self
          [:date, :time].each do |method|
            class_eval <<-END
              def relative_#{method}_restrictions(configuration)
                [:before, :after].collect do |option|
                  [configuration[option]].flatten.compact.collect do |item|
                    case item
                      when Symbol, Proc, #{method.to_s.camelize} then item
                      when String then Parser.parse_#{method}(item)
                      else raise RestrictionError, "\#{item.class}:\#{item} invalid. Use either a Proc, String, Symbol or #{method.to_s.camelize} object."
                    end
                  end
                end
              end
              
              def #{method}_meets_relative_restrictions(value, record, restrictions, method)
                restrictions = restrictions.select do |restriction|
                  begin
                    case restriction
                      when Symbol
                        value.send(method, record.send(restriction)) rescue false
                        
                      when Proc
                        result = restriction.call(record)
                        result = Parser.parse_#{method}(result) unless result.is_a?(#{method.to_s.camelize})
                        value.send(method, result)
                        
                      when #{method.to_s.camelize}
                        value.send(method, restriction)
                        
                      else
                        raise
                    end
                  rescue
                    raise RestrictionError, "Invalid restriction \#{restriction.class}:\#{restriction}"
                  end
                end
                
                restrictions.collect do |r|
                  case r
                    when Proc;   r.call(record)
                    when Symbol; r.to_s.humanize
                    else;        r
                  end
                end.first
              end
            END
          end
          
          alias_method :relative_date_time_restrictions, :relative_time_restrictions
          
          def date_before(value, record, restrictions)
            date_meets_relative_restrictions(value, record, restrictions, :>)
          end
          
          def date_after(value, record, restrictions)
            date_meets_relative_restrictions(value, record, restrictions, :<=)
          end
          
          def time_before(value, record, restrictions)
            time_meets_relative_restrictions(value, record, restrictions, :>)
          end
          
          def time_after(value, record, restrictions)
            time_meets_relative_restrictions(value, record, restrictions, :<=)
          end
          
          alias_method :date_time_before, :time_before
          alias_method :date_time_after,  :time_after
        end
      end
    end
  end
end
