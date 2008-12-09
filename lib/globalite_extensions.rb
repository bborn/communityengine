module StringExtension
  def localize(*args)
    if args.first.is_a? Symbol
      sym = args.shift
    else
      sym = underscore.tr(' ', '_').gsub(/[^a-z0-9_]+/i, '').to_sym
    end
      
    if AppConfig.show_localization_keys_for_debugging
      # wrap in a span to show the localization key
      return "<span class='localized' localization_key='#{sym}'>#{I18n.t(sym, *args)}</span>"
    else
      I18n.t(sym, *args)
    end
  end
  alias :l :localize
end 
String.send :include, StringExtension
 
 
module SymbolExtensionCustom
  DEBUG_EXEMPT = [:date_helper_order, :number_helper_order, :countries_list, :date_helper_month_names, :date_helper_abbr_month_names]
  
  def localize_with_debugging(*args)
    localized_sym = I18n.translate(self, *args)
        
    if !AppConfig.show_localization_keys_for_debugging 
      localized_sym
    elsif DEBUG_EXEMPT.include?(self)
      localized_sym
    else
      return "<span class='localized' localization_key='#{self.to_s}'>#{localized_sym}</span>"
    end
    
  end
  alias_method :l, :localize_with_debugging
  
  def l_with_args(*args)
    self.l(*args)
  end
  
end
 
Symbol.send :include, SymbolExtensionCustom