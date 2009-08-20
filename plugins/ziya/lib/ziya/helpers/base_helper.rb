module Ziya::Helpers
  module BaseHelper
    # =========================================================================
    # TODO Move to helper
    # -------------------------------------------------------------------------
    # YAML Convenience for component declaration   
    def component( component_name )
      "#{component_name}: #{clazz component_name, :Components}"
    end
    alias :comp :component
    
    # -------------------------------------------------------------------------
    # YAML Convenience for draw component class   
    def drawing( class_name )
      clazz( class_name, :Components )
    end

    # -------------------------------------------------------------------------
    # YAML Convenience for chart class   
    def chart( class_name )
      "--- #{clazz( class_name, :Charts )}" 
    end
   
   # -------------------------------------------------------------------------
    # YAML Convenience for chart name setting       
    def clazz( class_name, module_name=nil )
      buff = "!ruby/object:Ziya::"
      buff << "#{module_name}::" unless module_name.nil?
      buff << "#{camelize(class_name.to_s)}\n"
      buff
    end               
  end
end