# -----------------------------------------------------------------------------
# == Girder::Components::ChartBorder
#
# Sets up chart border configuration
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  # Sets the chart's border attributes.
  #
  # <tt>top_thickness</tt>:     The thickness of the border's top line. In polar charts, the top_thickness is ignored.
  #                             Valid values are zero and above. Zero makes this line invisible.
  #                             The default is zero.
  # <tt>bottom_thickness</tt>:  The thickness of the border's bottom line. In polar charts, the bottom_thickness is used
  #                             for the chart's outer border Valid values are zero and above. Zero makes this line invisible.
  #                             The default is zero for pie and bar charts, and 2 for all other charts.
  # <tt>left_thickness</tt>:    The thickness of the border's left line. In polar charts, the left_thickness is used for the
  #                             value-axis. Valid values are zero and above. Zero makes this line invisible.
  #                             The default is 2 for bar charts, and 0 for all other charts
  # <tt>right_thickness</tt>:   The thickness of the border's right line. In polar charts, the right_thickness is ignored.
  #                             Valid values are zero and above. Zero makes this line invisible.
  #                             The default is zero.
  # <tt>color</tt>:             The border color. This must be a string holding triple hexadecimal values representing
  #                             the red, green, and blue components for a color.
  #                             The default is "000000" (black).
  #
  # See http://www.maani.us/xml_charts/index.php?menu=Reference&submenu=chart_border
  # for additional documentation, examples and futher detail.
  class ChartBorder < Base  
    has_attribute :top_thickness, :bottom_thickness, :left_thickness,
                  :right_thickness, :color                      
  end
end