# -----------------------------------------------------------------------------
# Generates necessary xml for area chart 
# -----------------------------------------------------------------------------
module Ziya::Charts
  class Area < Base
    def initialize( license=nil, title=nil, chart_id=nil)
      super( license, title, chart_id )
      @type = "area"      
    end
  end
end