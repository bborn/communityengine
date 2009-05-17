# -----------------------------------------------------------------------------
# 
# -----------------------------------------------------------------------------
module Ziya::Charts
  class Polar < Base
    def initialize( license=nil, title=nil, chart_id=nil)
      super( license, title, chart_id )
      @type = "polar"      
    end
  end
end