Ckeditor.setup do |config|
  require "ckeditor/orm/active_record"

  config.default_per_page = 24

  config.assets_languages = ['en']

end
