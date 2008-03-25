# -----------------------------------------------------------------------------
# Generates necessary xml for a stack column chart
# -----------------------------------------------------------------------------
module Ziya::Charts
  class StackedColumn < Base
    def initialize( license=nil, title=nil, chart_id=nil)
      super( license, title, chart_id )
      @type = "stacked column"      
    end
  end
end