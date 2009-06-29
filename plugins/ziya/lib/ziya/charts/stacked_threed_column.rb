# -----------------------------------------------------------------------------
# Generates necessary xml for a stacked 3d column chart
# -----------------------------------------------------------------------------
module Ziya::Charts
  class StackedThreedColumn < Base
    def initialize( license=nil, title=nil, chart_id=nil)
      super( license, title, chart_id )
      @type = "stacked 3d column"      
    end
  end
end