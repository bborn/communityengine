# -----------------------------------------------------------------------------
# == Girder::Components::LegendRect
#
# Sets up chart legend location
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  # Sets the legend area and margin.
  #
  # <tt></tt>:
  #
  # See http://www.maani.us/xml_charts/index.php?menu=Reference&submenu=legend_rect
  # for additional documentation, examples and futher detail.
  class LegendRect < Base  
    has_attribute :x, :y, :width, :height, :margin, :fill_color, :fill_alpha,
                  :line_color, :line_alpha, :line_thickness
  end
end