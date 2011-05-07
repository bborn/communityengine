module TinyMCE
  # Setup a couple of Exception classes that we use later on
  class TinyMCEInvalidOption < Exception
    def self.invalid_option(option)
      new "Invalid option #{option} passed to tinymce"
    end
  end

  class TinyMCEInvalidOptionType < Exception
    def self.invalid_type_of(value, parameters={})
      new "Invalid value of type #{value.class} passed for TinyMCE option #{parameters[:for].to_s}"
    end
  end
end
