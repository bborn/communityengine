# -----------------------------------------------------------------------------
# == Girder::Components::ChartGridV
#
# Sets up chart vertical grid configuration
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  # Sets the chart's vertical grid attributes.
  #
  # <tt>thickness</tt>:   The thickness of the grid's vertical lines. Valid values are zero and above.
  #                       Zero makes the vertical lines invisible.
  #                       The default is zero.
  # <tt>color</tt>:       The grid's vertical color. This must be a string holding triple hexadecimal values
  #                       representing the red, green, and blue components for a color.
  #                       The default is "000000" (black).
  # <tt>alpha</tt>:       The grid's vertical transparency value. Valid values are 0 (fully transparent)
  #                       to 100 (fully opaque).
  #                       The default is 20.
  # <tt>type</tt>:        The grid's vertical line type. Valid values are solid, dotted, and dashed.
  #                       The default is solid.
  #
  # See http://www.maani.us/xml_charts/index.php?menu=Reference&submenu=chart_grid_v
  # for additional documentation, examples and futher detail.
  class ChartGridV < Base  
    has_attribute :thickness, :color, :alpha, :type                 
  end
end