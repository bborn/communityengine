module SymbolExtension # :nodoc:
  # Localizes the symbol into the current locale. 
  # If there is no translation available, the replacement string will be returned
  def localize(replacement_string = '__localization_missing__', args={})
    Globalite.localize(self, replacement_string, args)
  end
  alias :l :localize
  
  def l_in(locale, args={})
    Globalite.localize(self, '_localization_missing_', args, locale) unless locale.nil?
  end
  
  # Note that this method takes the replacement string after the args hash unlike other Globalite methods
  def localize_with_args(args={}, replacement_string = '__localization_missing__')
    Globalite.localize(self, replacement_string, args)
  end
  alias :l_with_args :localize_with_args
  
end

module StringExtension
  def localize(*args)
    if args.first.is_a? Symbol
      sym = args.shift
    else
      sym = underscore.tr(' ', '_').gsub(/[^a-z1-9_]+/i, '').to_sym
    end
    
    if Globalite.show_localization_keys_for_debugging
      # wrap in a span to show the localization key
      return "<span localization_key='#{sym}'>#{sym.localize(self, *args)}</span>"
    else
      sym.localize(self, *args)
    end
  end
  alias :l :localize
  
end
