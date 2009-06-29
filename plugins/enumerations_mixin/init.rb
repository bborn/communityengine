# Copyright (c) 2005 Trevor Squires
# Released under the MIT License.  See the LICENSE file for more details.

require 'active_record/acts/enumerated'
require 'active_record/aggregations/has_enumerated'
ActiveRecord::Base.class_eval do
  include ActiveRecord::Acts::Enumerated
  include ActiveRecord::Aggregations::HasEnumerated
end

# Virtual enumerations are useful if you've got a ton of different
# enumerations and don't care to litter your models directory with them.
# It's also handy if you want to define singleton methods for your
# enumerated values.
# See virtual_sample.txt in this directory for more info
if File.exist?("#{RAILS_ROOT}/config/virtual_enumerations.rb")
  require 'active_record/virtual_enumerations'
  silence_warnings do
    eval(IO.read("#{RAILS_ROOT}/config/virtual_enumerations.rb"), binding)
  end
end
