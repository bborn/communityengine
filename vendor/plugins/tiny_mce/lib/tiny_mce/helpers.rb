module TinyMCE
  # The helper module we include into ActionController::Base
  module Helpers

    # Has uses_tiny_mce method been declared in the controller for this page?
    def using_tiny_mce?
      !@uses_tiny_mce.blank?
    end

    def tiny_mce_configurations
      @tiny_mce_configurations ||= [Configuration.new]
    end

    # Parse @tiny_mce_options and @raw_tiny_mce_options to create a raw JS string
    # used by TinyMCE. Returns errors if the option or options type is invalid
    def raw_tiny_mce_init(options = {}, raw_options = nil)
      tinymce_js = ""

      tiny_mce_configurations.each do |configuration|
        configuration.add_options(options, raw_options)
        tinymce_js += "tinyMCE.init("
        tinymce_js += configuration.to_json
        tinymce_js += ");"        
      end

      tinymce_js
    end

    # Form the raw JS and wrap in in a <script> tag for inclusion in the <head>
    def tiny_mce_init(options = {}, raw_options = nil)
      javascript_tag raw_tiny_mce_init(options, raw_options)
    end

    def tiny_mce_init_if_needed(options = {}, raw_options = nil)
      tiny_mce_init(options, raw_options) if using_tiny_mce?
    end

    def include_tiny_mce_if_needed(options = {}, raw_options = nil)
      tiny_mce_init_if_needed(options, raw_options)
    end

  end
end
