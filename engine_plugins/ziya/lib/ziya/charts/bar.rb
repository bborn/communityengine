# -----------------------------------------------------------------------------
# Generates necessary xml for a StackColumn chart
# -----------------------------------------------------------------------------
module Ziya::Charts
  class Bar < Base
    def initialize( license=nil, title=nil, chart_id=nil)
      super( license, title, chart_id )
      @type = "bar"      
    end
  end
end