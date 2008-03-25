# -----------------------------------------------------------------------------
# Generates necessary xml for floating bar chart
# -----------------------------------------------------------------------------
module Ziya::Charts
  class FloatingBar < Base
    def initialize( license=nil, title=nil, chart_id=nil)
      super( license, title, chart_id )
      @type = "floating bar"      
    end
  end
end