
require 'globalite_extensions'
I18n.load_path += Dir[ (File.join(RAILS_ROOT, "vendor", "plugins", "community_engine", "lang", "ui", '*.{rb,yml}')) ]
I18n.load_path += Dir[ (File.join(RAILS_ROOT, "lang", "ui", '*.{rb,yml}')) ]
# I18n.load_path += Dir[ (File.join(RAILS_ROOT, "lang", "rails", '*.{rb,yml}')) ]
I18n.default_locale = "en"
I18n.reload!



#patch, because Rails date_select is broken
#see: http://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/1389-error-with-date_select-when-a-default_locale-is-set

module ActionView
  module Helpers
    class DateTimeSelector
      def translated_date_order
        begin
          order = I18n.translate(:'date.order', :locale => @options[:locale])
          if order.respond_to?(:to_ary)
            order
          else
            [:year, :month, :day]
          end
        end
      end
    end
  end
end
