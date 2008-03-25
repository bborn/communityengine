# -----------------------------------------------------------------------------
# Generates necessary xml for a StackColumn chart
# -----------------------------------------------------------------------------
module Ziya::Charts
  class Column < Base
    def initialize( license=nil, title=nil, chart_id=nil)
      super( license, title, chart_id )
      @type = "column"      
    end
  end
end