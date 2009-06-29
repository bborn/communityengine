# -----------------------------------------------------------------------------
# Generates necessary xml for stacked area chart 
# -----------------------------------------------------------------------------
module Ziya::Charts
  class StackedArea < Base
    def initialize( license=nil, title=nil, chart_id=nil)
      super( license, title, chart_id )
      @type = "stacked area"      
    end
  end
end