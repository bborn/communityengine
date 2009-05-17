# -----------------------------------------------------------------------------
# == Girder::Components::ChartGridH
#
# Sets up chart horizontal grid configuration
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  # Sets the chart's horizontal grid attributes.
  #
  # <tt>thickness</tt>:   The thickness of the grid's horizontal lines. Valid values are zero and above.
  #                       Zero makes the horizontal lines invisible.
  #                       The default is 1.
  # <tt>color</tt>:       The grid's horizontal color. This must be a string holding triple hexadecimal
  #                       values representing the red, green, and blue components for a color.
  #                       The default is "000000" (black).
  # <tt>alpha</tt>:       The grid's horizontal transparency value. Valid values are 0 (fully transparent)
  #                       to 100 (fully opaque).
  #                       The default is 20.
  # <tt>type</tt>:        The grid's horizontal line type. Valid values are solid, dotted, and dashed.
  #                       The default is solid.
  #
  # See http://www.maani.us/xml_charts/index.php?menu=Reference&submenu=chart_grid_h
  # for additional documentation, examples and futher detail.
  class ChartGridH < Base  
    has_attribute :thickness, :color, :alpha, :type           
  end
end