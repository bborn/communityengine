module Ziya
  module Charting
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def ziya_theme(name)
        Ziya::Charts::Base.theme(name)
      end
      alias :chart_theme :ziya_theme
    end
  end
end

ActionController::Base.send(:include, Ziya::Charting)