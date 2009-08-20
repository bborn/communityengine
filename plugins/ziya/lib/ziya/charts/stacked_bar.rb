# -----------------------------------------------------------------------------
# Generates necessary xml for a stacked bar chart
# -----------------------------------------------------------------------------
module Ziya::Charts
  class StackedBar < Base
    def initialize( license=nil, title=nil, chart_id=nil)
      super( license, title, chart_id )
      @type = "stacked bar"      
    end
  end
end