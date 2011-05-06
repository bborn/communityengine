module StringExtension
  def localize(*args)
    if args.first.is_a? Symbol
      sym = args.shift
    else
      sym = underscore.tr(' ', '_').gsub(/[^a-z0-9_]+/i, '').to_sym
    end
    args << {:default => self}
      
    I18n.t(sym, *args).html_safe
  end
  alias :l :localize
end 
String.send :include, StringExtension
 
 
module SymbolExtensionCustom
  
  def localize_with_debugging(*args)
    localized_sym = I18n.translate(self, *args)
    localized_sym.is_a?(String) ? localized_sym.html_safe : localized_sym
  end
  alias_method :l, :localize_with_debugging
  
  def l_with_args(*args)
    self.l(*args).html_safe
  end
  
end
 
Symbol.send :include, SymbolExtensionCustom