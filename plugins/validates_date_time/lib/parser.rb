module ActiveRecord
  module Validations
    module DateTime
      module Parser
        class DateParseError < StandardError #:nodoc:
        end
        class TimeParseError < StandardError #:nodoc:
        end
        class DateTimeParseError < StandardError #:nodoc:
        end
        
        class << self
          def parse_date(value)
            raise if value.blank?
            return value if value.is_a?(Date)
            return value.to_date if value.is_a?(Time)
            raise unless value.is_a?(String)
            
            year, month, day = case value.strip
              # 22/1/06, 22\1\06 or 22.1.06
              when /\A(\d{1,2})[\\\/\.-](\d{1,2})[\\\/\.-](\d{2}|\d{4})\Z/
                ActiveRecord::Validations::DateTime.us_date_format ? [$3, $1, $2] : [$3, $2, $1]
              # 22 Feb 06 or 1 jun 2001
              when /\A(\d{1,2}) (\w{3,9}) (\d{2}|\d{4})\Z/
                [$3, $2, $1]
              # July 1 2005
              when /\A(\w{3,9}) (\d{1,2}) (\d{2}|\d{4})\Z/
                [$3, $1, $2]
              # 2006-01-01
              when /\A(\d{4})-(\d{2})-(\d{2})\Z/
                [$1, $2, $3]
              # Not a valid date string
              else raise
            end
            
            Date.new(unambiguous_year(year), month_index(month), day.to_i)
          rescue
            raise DateParseError
          end
          
          def parse_time(value)
            raise if value.blank?
            return value if value.is_a?(Time)
            return value.to_time if value.is_a?(Date)
            raise unless value.is_a?(String)
            
            hour, minute, second = case value.strip
              # 12 hour with minute: 7.30pm, 11:20am, 2 20PM
              when /\A(\d{1,2})[\. :](\d{2})\s?(am|pm)\Z/i
                [full_hour($1, $3), $2]
              # 12 hour without minute: 2pm, 11Am, 7 pm
              when /\A(\d{1,2})\s?(am|pm)\Z/i
                [full_hour($1, $2)]
              # 24 hour: 22:30, 03.10, 12 30
              when /\A(\d{2})[\. :](\d{2})([\. :](\d{2}))?\Z/
                [$1, $2, $4]
              # Not a valid time string
              else raise
            end
            
            Time.send(ActiveRecord::Base.default_timezone, 2000, 1, 1, hour.to_i, minute.to_i, second.to_i)
          rescue
            raise TimeParseError
          end
          
          def parse_date_time(value)
            raise if value.blank?
            return value if value.is_a?(Time)
            return value.to_time if value.is_a?(Date)
            raise unless value.is_a?(String)
            
            value = value.strip
            
            # The basic approach is to attempt to parse a date from the front of the string, splitting on spaces.
            # Once a date has been parsed, a time is extracted from the rest of the string.
            split_index = 0
            until false do
              split_index = value.index(' ', split_index == 0 ? 0 : split_index + 1)
              break if !split_index or (date = parse_date(value[0..split_index]) rescue nil)
            end
            
            time = parse_time(value[split_index + 1..value.size]) if split_index
            
            Time.send(ActiveRecord::Base.default_timezone, date.year, date.month, date.day, time.hour, time.min, time.sec)
          rescue
            raise DateTimeParseError
          end
          
          def full_hour(hour, meridian)
            hour = hour.to_i
            if meridian.strip.downcase == 'am'
              hour == 12 ? 0 : hour
            else
              hour == 12 ? hour : hour + 12
            end
          end
          
          def month_index(month)
            return month.to_i if month.to_i.nonzero?
            Date::ABBR_MONTHNAMES.index(month.capitalize) || Date::MONTHNAMES.index(month.capitalize)
          end
          
          # Extract a 4-digit year from a 2-digit year.
          # If the number is less than 20, assume year 20#{number}
          # otherwise use 19#{number}. Ignore if already 4 digits.
          #
          # Eg:
          #    10 => 2010, 60 => 1960, 00 => 2000, 1963 => 1963
          def unambiguous_year(year)
            year = "#{year.to_i < 20 ? '20' : '19'}#{year}" if year.length == 2
            year.to_i
          end
        end
      end
    end
  end
end
