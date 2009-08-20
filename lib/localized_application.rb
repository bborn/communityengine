# Adds logic for the Globalite plugin.

module LocalizedApplication
  # Set the locale from the parameters, the session, or the navigator
  # If none of these works, the Globalite default locale is set (en-*)
  def set_locale
    if RAILS_ENV.eql?('test')
      AppConfig.community_locale = 'en'
    end
    # Get the current path and request method (useful in the layout for changing the language)
    @current_path = request.env['PATH_INFO']
    @request_method = request.env['REQUEST_METHOD']

    if AppConfig.community_locale
        logger.debug "[I18n] loading locale: #{AppConfig.community_locale} from config"
        I18n.locale = AppConfig.community_locale
    else
        I18n.locale = get_valid_lang_from_accept_header
        logger.debug "[I18n] found a valid http header locale: #{I18n.locale}"
    end
    
    logger.debug "[I18n] Locale set to #{I18n.locale}"
    # render the page

    yield

    # reset the locale to its default value
    I18n.locale = I18n.default_locale
  end

  # Get a sorted array of the navigator languages
  def get_sorted_langs_from_accept_header
    accept_langs = (request.env['HTTP_ACCEPT_LANGUAGE'] || "en-us,en;q=0.5").split(/,/) rescue nil
    return nil unless accept_langs

    # Extract langs and sort by weight
    # Example HTTP_ACCEPT_LANGUAGE: "en-au,en-gb;q=0.8,en;q=0.5,ja;q=0.3"
    wl = {}
    accept_langs.each {|accept_lang|
        if (accept_lang + ';q=1') =~ /^(.+?);q=([^;]+).*/
            wl[($2.to_f rescue -1.0)]= $1
        end
    }
    logger.debug "[I18n] client accepted locales: #{wl.sort{|a,b| b[0] <=> a[0] }.map{|a| a[1] }.to_sentence}"
    sorted_langs = wl.sort{|a,b| b[0] <=> a[0] }.map{|a| a[1] }
  end

  # Returns a valid language that best suits the HTTP_ACCEPT_LANGUAGE request header.
  # If no valid language can be deduced, then <tt>nil</tt> is returned.
  def get_valid_lang_from_accept_header
    # Get the sorted navigator languages and find the first one that matches our available languages
    get_sorted_langs_from_accept_header.detect do |l|
      my_locale = get_matching_ui_locale(l)
      return my_locale if !my_locale.nil?
    end
  end

  # Returns the UI locale that best matches with the parameter
  # or nil if not found
  def get_matching_ui_locale(locale)
    lang = locale[0,2].downcase
    to_try = Array.new()
    if locale[3,5]
      country = locale[3,5].upcase
      logger.debug "[I18n] trying to match locale: #{lang}-#{country} and #{lang}-*"
      to_try << "#{lang}-#{country}".to_sym
      to_try << "#{lang}-*".to_sym
    else
      logger.debug "[I18n] trying to match #{lang}-*"
      to_try << "#{lang}-*".to_sym
    end

    # Check with exact matching
    to_try.each do |possible_locale|
      # if Globalite.ui_locales.values.include?(possible_locale)
      #   logger.debug "[I18n] Globalite does include #{locale} matching #{possible_locale}"
        return possible_locale
      # end
    end

    return nil
  end  
end