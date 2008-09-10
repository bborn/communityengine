module StringExtension
  def localize(*args)
    if args.first.is_a? Symbol
      sym = args.shift
    else
      sym = underscore.tr(' ', '_').gsub(/[^a-z0-9_]+/i, '').to_sym
    end
      
    if Globalite.show_localization_keys_for_debugging
      # wrap in a span to show the localization key
      return "<span class='localized' localization_key='#{sym}'>#{sym.localize(self, *args)}</span>"
    else
      sym.localize(self, *args)
    end
  end
  alias :l :localize
end
 
 
String.send :include, StringExtension
 
module Globalite
    module L10n
      @@show_localization_keys_for_debugging = false
      attr_accessor :show_localization_keys_for_debugging
     end
end
 
module SymbolExtensionCustom
  DEBUG_EXEMPT = [:date_helper_order, :number_helper_order, :countries_list, :date_helper_month_names, :date_helper_abbr_month_names]
  
  def localize_with_debugging(*args)
    if args.first.is_a? Hash
      localized_sym = self.localize_with_args(*args)
    else
      localized_sym = self.localize(*args)
    end
    
    if !Globalite.show_localization_keys_for_debugging 
      localized_sym
    elsif DEBUG_EXEMPT.include?(self)
      localized_sym
    else
      return "<span class='localized' localization_key='#{self.to_s}'>#{localized_sym}</span>"
    end
  end
  alias_method :l, :localize_with_debugging
end
 
Symbol.send :include, SymbolExtensionCustom