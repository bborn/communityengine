module TinyMCE
  class Configuration
    # We use this to combine options and raw_options into one class and validate
    # whether options passed in by the users are valid tiny mce configuration settings.
    # Also loads which options are valid, and provides an plugins attribute to allow
    # more configuration options dynamicly

    # The default tiny_mce options. Tries it's best to determine the locale
    # If the current locale doesn't have a lang in TinyMCE, default to en
    def self.default_options
      locale = I18n.locale.to_s[0,2] if defined?(I18n)
      locale = :en unless locale && valid_langs.include?(locale)
      { 'mode' => 'textareas', 'editor_selector' => 'mceEditor',
        'theme' => 'simple',   'language' => locale }
    end

    # The YAML file might not exist, might be blank, might be invalid, or
    # might be valid. Catch all cases and make sure we always return a Hash
    # Run it through an ERB parser so that environment specific code can be
    # put in the file
    def self.config_file_options
      @@config_file_options ||= begin
        tiny_mce_yaml_filepath = File.join(::Rails.root.to_s, 'config', 'tiny_mce.yml')
        return Hash.new unless File.exist?(tiny_mce_yaml_filepath)
        tiny_mce_config = IO.read(tiny_mce_yaml_filepath)
        tiny_mce_config = ERB.new(tiny_mce_config).result if defined?(ERB)
        (YAML::load(tiny_mce_config) rescue nil) || Hash.new
      end
    end

    # Parse the valid langs file and load it into an array
    def self.valid_langs
      @@valid_langs ||= begin
        valid_langs_path = File.join(File.dirname(__FILE__), 'valid_tinymce_langs.yml')
        File.open(valid_langs_path) { |f| YAML.load(f.read) }
      end
    end

    # Parse the valid options file and load it into an array
    def self.valid_options
      @@valid_options ||= begin
        valid_options_path = File.join(File.dirname(__FILE__), 'valid_tinymce_options.yml')
        File.open(valid_options_path) { |f| YAML.load(f.read) }
      end
    end

    attr_accessor :options, :raw_options

    def initialize(options = {}, raw_options = nil)
      options = Hash.new unless options.is_a?(Hash)
      @options = self.class.default_options.
                            merge(self.class.config_file_options.stringify_keys).
                            merge(options.stringify_keys)
      @raw_options = [raw_options]
    end

    # Merge additional options and raw_options
    def add_options(options = {}, raw_options = nil)
      @options.merge!(options.stringify_keys) unless options.blank?
      @raw_options << raw_options unless raw_options.blank?
    end

    # Merge additional options and raw_options, but don't overwrite existing
    def reverse_add_options(options = {}, raw_options = nil)
      @options.reverse_merge!(options.stringify_keys) unless options.blank?
      @raw_options << raw_options unless raw_options.blank?
    end

    def plugins
      @options['plugins'] || []
    end

    # Validate and merge options and raw_options into a string
    # to be used for tinyMCE.init() in the raw_tiny_mce_init helper
    def to_json
      raise TinyMCEInvalidOptionType.invalid_type_of(plugins, :for => :plugins) unless plugins.is_a?(Array)

      json_options = []
      @options.each_pair do |key, value|
        raise TinyMCEInvalidOption.invalid_option(key) unless valid?(key)
        json_options << "#{key} : " + case value
        when String, Symbol, Fixnum
          "'#{value.to_s}'"
        when Array
          '"' + value.join(',') + '"'
        when TrueClass
          'true'
        when FalseClass
          'false'
        else
          raise TinyMCEInvalidOptionType.invalid_type_of(value, :for => key)
        end
      end

      json_options.sort!

      @raw_options.compact!
      json_options += @raw_options unless @raw_options.blank?

      "{\n" + json_options.delete_if {|o| o.blank? }.join(",\n") + "\n\n}"
    end

    # Does the check to see if the option is valid. It checks the valid_options
    # array (see above), checks if the start of the option name is in the plugin list
    # or checks if it's an theme_advanced_container setting
    def valid?(option)
      option = option.to_s
      self.class.valid_options.include?(option) ||
        plugins.include?(option.split('_').first) ||
        option =~ /^theme_advanced_container_\w+$/
    end
  
  end
end
