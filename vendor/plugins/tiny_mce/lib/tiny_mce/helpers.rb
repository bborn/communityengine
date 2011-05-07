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
        
        if uses_jquery?
          #TODO: Use dynamic editor_selector from configuration
          tinymce_js += "$(function(){ $('textarea.mceEditor').tinymce("
          tinymce_js += configuration.to_json
          tinymce_js += ");"
          tinymce_js += "});"
        else
          tinymce_js += "tinyMCE.init("
          tinymce_js += configuration.to_json
          tinymce_js += ");"
        end
        
      end

      tinymce_js
    end

    # Form the raw JS and wrap in in a <script> tag for inclusion in the <head>
    def tiny_mce_init(options = {}, raw_options = nil)
      javascript_tag raw_tiny_mce_init(options, raw_options)
    end
    # Form the raw JS and wrap in in a <script> tag for inclusion in the <head>
    # (only if tiny mce is actually being used)
    def tiny_mce_init_if_needed(options = {}, raw_options = nil)
      tiny_mce_init(options, raw_options) if using_tiny_mce?
    end

    # Form a JS include tag for the TinyMCE JS src for inclusion in the <head>
    # Attempt to use the jQuery plugin if the application appears to be using jquery
    def include_tiny_mce_js
      if uses_jquery?
        javascript_include_tag "tiny_mce/jquery.tinymce"
      else
        javascript_include_tag(Rails.env.to_s == 'development' ? "tiny_mce/tiny_mce_src" : "tiny_mce/tiny_mce")
      end
    end
    # Form a JS include tag for the TinyMCE JS src for inclusion in the <head>
    # (only if tiny mce is actually being used)
    def include_tiny_mce_js_if_needed
      include_tiny_mce_js if using_tiny_mce?
    end

    # Form a JS include tag for the TinyMCE JS src, and form the raw JS and wrap
    # in in a <script> tag for inclusion in the <head> for inclusion in the <head>
    # (only if tiny mce is actually being used)
    def include_tiny_mce_if_needed(options = {}, raw_options = nil)
      if using_tiny_mce?
        include_tiny_mce_js + tiny_mce_init(options, raw_options)
      end
    end

    private

    def uses_jquery?
      uses_jquery = false
      tiny_mce_configurations.each do |configuration|
        if configuration.uses_jquery?
          uses_jquery = true
          break
        end
      end
      uses_jquery
    end

  end
end
