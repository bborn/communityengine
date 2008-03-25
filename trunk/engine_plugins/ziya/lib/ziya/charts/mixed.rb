# -----------------------------------------------------------------------------
# Generates necessary xml for mixed chart 
# -----------------------------------------------------------------------------
module Ziya::Charts
  class Mixed < Base
    def initialize( license=nil, title=nil, chart_id=nil )
      super( license, title, chart_id )
      @type = nil      
    end
  end
end