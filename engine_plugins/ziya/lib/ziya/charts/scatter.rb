# -----------------------------------------------------------------------------
# Generates necessary xml for scatter chart 
# -----------------------------------------------------------------------------
module Ziya::Charts
  class Scatter < Base
    def initialize( license=nil, title=nil, chart_id=nil)
      super( license, title, chart_id )
      @type = "scatter"      
    end
  end
end         
