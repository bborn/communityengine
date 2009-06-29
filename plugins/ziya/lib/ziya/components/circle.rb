# -----------------------------------------------------------------------------
# == Girder::Components::Circle
#
# Draws a circle
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  class Circle < Base  
    has_attribute :layer, :transition, :delay, :duration, :x, :y, :radius,
                  :fill_color, :fill_alpha, :line_color, :line_alpha,
                  :line_thickness              
  end
end