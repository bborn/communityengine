require 'globalite'
# Load the base translations, and the app overrides
Globalite.add_localization_source(File.join(RAILS_ROOT, "vendor", "plugins", "community_engine", "lang", "ui"))
Globalite.add_localization_source(File.join(RAILS_ROOT, "lang", "ui"))