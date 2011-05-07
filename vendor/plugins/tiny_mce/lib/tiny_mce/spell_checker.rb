# The base module we include into ActionController::Base
module TinyMCE

  # Provides Spell checking capability to tiny_mce plugin
  # Note: this may not always be up to date.
  # Please supply patches if this isn't working
  module SpellChecker

    require 'net/https'
    require 'uri'
    require 'rexml/document'

    ASPELL_WORD_DATA_REGEX = Regexp.new(/\&\s\w+\s\d+\s\d+(.*)$/)

    # Attempt to determine where Aspell is
    # Might be slow and a horrible way to do it, but it works!
    # Should also grab Mac OS X and Window path's instead of assuming linux
    aspell_path = nil
    ['/usr/bin/aspell', '/usr/local/bin/aspell'].each do |path|
      if File.exists?(path)
        aspell_path = path
        break
      end
    end
    ASPELL_PATH = aspell_path || "aspell" # fall back to a pathless call

    # The method called via AJAX request by the Spellchecking plugin in TinyMCE.
    # Passes in various params (language, words, and method)
    # Return a JSON object required by the Spellchecking plugin
    def spellchecker
      language, words, method = params[:params][0], params[:params][1], params[:method] unless params[:params].blank?
      return render(:nothing => true) if language.blank? || words.blank? || method.blank?
      headers["Content-Type"] = "text/plain"
      headers["charset"] = "utf-8"
      suggestions = check_spelling(words, method, language)
      results = {"id" => nil, "result" => suggestions, "error" => nil}
      render :json => results
    end

    private

    # This method is called by the spellchecker action.
    # Is sends a command to the system, and parses the output
    # Returns different value depending on the command (checking words, or getting suggestions)
    def check_spelling(spell_check_text, command, lang)
      xml_response_values = Array.new
      spell_check_text = spell_check_text.join(' ') if command == 'checkWords'
      logger.debug("Spellchecking via:  echo \"#{spell_check_text}\" | #{ASPELL_PATH} -a -l #{lang}")
      spell_check_response = `echo "#{spell_check_text}" | #{ASPELL_PATH} -a -l #{lang}`
      return xml_response_values if spell_check_response.blank?
      spelling_errors = spell_check_response.split("\n").slice(1..-1)
      for error in spelling_errors
        error.strip!
        if (match_data = error.match(ASPELL_WORD_DATA_REGEX))
          if (command == 'checkWords')
            arr = match_data[0].split(' ')
            xml_response_values << arr[1]
          elsif (command == 'getSuggestions')
            xml_response_values << error.split(',')[1..-1].collect(&:strip!)
            xml_response_values = xml_response_values.first
          end
        end
      end
      return xml_response_values
    end
  end
end
