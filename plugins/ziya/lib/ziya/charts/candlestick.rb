# -----------------------------------------------------------------------------
# Generates necessary xml for candlestick chart 
# -----------------------------------------------------------------------------
module Ziya::Charts
  class CandleStick < Base
    def initialize( license=nil, title=nil, chart_id=nil)
      super( license, title, chart_id )
      @type = "candlestick"      
    end
  end
end