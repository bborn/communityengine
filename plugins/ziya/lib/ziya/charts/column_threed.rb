# -----------------------------------------------------------------------------
# Generates necessary xml for 3D column chart
# -----------------------------------------------------------------------------
module Ziya::Charts
  class ColumnThreed < Base
    def initialize( license=nil, title=nil, chart_id=nil)
      super( license, title, chart_id )
      @type = "3d column"      
    end
  end
end