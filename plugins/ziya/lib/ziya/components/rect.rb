# -----------------------------------------------------------------------------
# == SwfCharts::Components::Rect
#
# Draw a rectangle on a chart
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  class Rect < Base  
    has_attribute :layer, :transition, :delay, :duration, :x, :y, :width,
                  :height, :fill_color, :fill_alpha, :line_color, :line_alpha,
                  :line_thickness
  end
end