# -----------------------------------------------------------------------------
# == Ziya::Utils::Text
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
#
# Various text utils. Yes indeed lifted from Inflecto to remove Inflector 
# dependencies...
#
# -----------------------------------------------------------------------------
module Ziya::Utils
  module Text
    # Pulled from the Rails Inflector class and modified slightly to fit our needs.
    def camelize(string)
      string.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
    end

    # Same as Rails Inflector but eliminating inflector dependency
    def underscore(camel_cased_word)
      camel_cased_word.to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
      downcase
    end

    # Pulled from the Rails Inflector class and modified slightly to fit our needs.
    def classify(string)
      camelize(string.to_s.sub(/.*\./, ''))
    end
  end  
end