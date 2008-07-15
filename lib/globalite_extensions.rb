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


String.send :include, StringExtension

module Globalite
    module L10n   
      @@show_localization_keys_for_debugging = false
      attr_accessor :show_localization_keys_for_debugging    
     end
end