# -----------------------------------------------------------------------------
# == Girder::Components::Line
#
# Draw a line on a chart
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  class Line < Base  
    has_attribute :layer, :transition, :delay, :duration, :x1, :y1, :x2, :y2,
                  :line_color,:line_alpha, :line_thickness
  end
end