require "rails"

class EnumerationsMixin < Rails::Engine
  config.autoload_paths << File.expand_path(File.join(__FILE__, "../"))

  initializer 'enumerations_mixin' do
    ActiveSupport.on_load(:active_record) do
      include ActiveRecord::Acts::Enumerated
      include ActiveRecord::Aggregations::HasEnumerated
    end
  end
end
