# -----------------------------------------------------------------------------
# 
# -----------------------------------------------------------------------------
module Ziya::Charts
  class Pie < Base
    def initialize( license=nil, title=nil, chart_id=nil)
      super( license, title, chart_id )
      @type = "pie"      
    end
  end
end