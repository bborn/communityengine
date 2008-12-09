
require 'globalite_extensions'
I18n.load_path += Dir[ (File.join(RAILS_ROOT, "vendor", "plugins", "community_engine", "lang", "ui", '*.{rb,yml}')) ]
I18n.load_path += Dir[ (File.join(RAILS_ROOT, "lang", "ui", '*.{rb,yml}')) ]
I18n.default_locale = "de-DE"
