module StringExtension
  def localize(*args)
    if args.first.is_a? Symbol
      sym = args.shift
    else
      sym = underscore.tr(' ', '_').gsub(/[^a-z1-9_]+/i, '').to_sym
    end
    
    if Globalite.show_localization_keys_for_debugging
      # wrap in a span to show the localization key
      return "<span class='localized' localization_key='#{sym}'>#{sym.localize(self, *args)}</span>"
    else
      sym.localize(self, *args)
    end
  end
  alias :l :localize
  alias :_ :localize
end


String.send :include, StringExtension

module Globalite
    module L10n   
      @@show_localization_keys_for_debugging = false
      attr_accessor :show_localization_keys_for_debugging    
     end
end

module SymbolExtensionCustom
  def extended_localize(*args)
    if args.first.is_a? Hash
      if Globalite.show_localization_keys_for_debugging
        # wrap in a span to show the localization key
        return "<span class='localized' localization_key='#{self.to_s}'>#{self.localize_with_args(*args)}</span>"
      else
        self.localize_with_args(*args)
      end
    else
      if Globalite.show_localization_keys_for_debugging
        # wrap in a span to show the localization key
        return "<span class='localized' localization_key='#{self.to_s}'>#{self.localize(*args)}</span>"
      else
        self.localize(*args)
      end
    end    
  end
  alias :_ :extended_localize
  
end

Symbol.send :include, SymbolExtensionCustom