# -----------------------------------------------------------------------------
# == Girder::Components::ChartRect
#
# Sets up the content area the chart occupies
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  # Sets the chart's rectangle
  #
  # <tt>x</tt>:               The horizontal position of the rectangle's upper left corner relative to the upper
  #                           left corner of the canvas (0, 0).
  # <tt>y</tt>:               The vertical position of the rectangle's upper left corner relative to the upper
  #                           left corner of the canvas (0, 0).
  # <tt>width</tt>:           The rectangle's width.
  # <tt>height</tt>:          The rectangle's height.
  # <tt>positive_color</tt>:  The chart's background color above the zero line. This must be a string holding triple
  #                           hexadecimal values representing the red, green, and blue components for a color.
  #                           The default is "FFFFFF" (white).
  # <tt>negative_color</tt>:  The chart's background color below the zero line. This must be a string holding triple
  #                           hexadecimal values representing the red, green, and blue components for a color.
  #                           The default is "000000" (black).
  # <tt>positive_alpha</tt>:  The transparency value of the background color above the zero line. Valid values are 0
  #                           (fully transparent) to 100 (fully opaque).
  #                           The default is 75.
  # <tt>negative_alpha</tt>:  The transparency value of the background color below the zero line. Valid values are 0
  #                           (fully transparent) to 100 (fully opaque).
  #                           The default is 20.
  #
  # See http://www.maani.us/xml_charts/index.php?menu=Reference&submenu=chart_rect
  # for additional documentation, examples and futher detail.
  class ChartRect < Base
    has_attribute :x, :y, :width, :height, :positive_color, :negative_color,
                  :positive_alpha, :negative_alpha             
  end
end