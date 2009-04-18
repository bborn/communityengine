# -----------------------------------------------------------------------------
# == Girder::Components::ChartValue
#
# Sets up chart labels configuration. These are the labels on top on the chart.
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  # Sets the label attributes for the values appearing on top of the chart.
  #
  # <tt>prefix</tt>:            The characters to add before the value numbers (example: $10).
  #                             The default is nothing.
  # <tt>suffix</tt>:            The characters to add after the value numbers (example: 10%).
  #                             The default is nothing.
  # <tt>decimals</tt>:          The number of decimal places to the right of the decimal point (example: 10.45).
  #                             The default is zero (no decimals)
  # <tt>decimal_char</tt>:      The character to use at the left of a decimal fraction (example: 1.5).
  #                             The default is '.' (dot or full stop).
  # <tt>separator</tt>:         The character to place between every group of thousands (example: 1,00,000).
  #                             The default is nothing.
  # <tt>position</tt>:          The position where to place the values. Each chart type has a different set of valid values.
  #                               -   Line chart: center, above, below, left, right, cursor, hide
  #                               -   Column chart: top, bottom, middle, outside, cursor, hide
  #                               -   Stacked Column chart: top, bottom, middle, cursor, hide
  #                               -   Floating Column chart: inside, outside, cursor, hide
  #                               -   Stacked 3D Column chart: middle, cursor, hide
  #                               -   Floating 3D Column chart: over, middle, cursor, hide
  #                               -   Pie charts: inside, outside, cursor, hide
  #                               -   3D Pie charts: inside, outside, cursor, hide
  #                               -   Bar chart: left, center, right, outside, cursor, hide
  #                               -   Stacked Bar chart: left, center, right, cursor, hide
  #                               -   Floating Bar chart: inside, outside, cursor, hide
  #                               -   Area chart: center, above, below, left, right, cursor, hide
  #                               -   Stacked Area chart: center, above, below, left, right, cursor, hide
  #                               -   Candlestick chart: cursor, hide
  #                               -   Scatter chart: center, above, below, left, right, cursor, hide
  #                               -   Polar chart: center, above, below, left, right, cursor, hide
  #                               -   Mixed chart: If one position key belonging to the above chart types isn't
  #                                                sufficient to show all the labels on a mixed chart, add more
  #                                                keys separated by underscores. For example, a column and line
  #                                                mixed chart can have the position key "top_above".
  # <tt>hide_zero</tt>:         This determines whether to hide value labels equal to zero.
  #                             The default is false (shows zero labels).
  # <tt>as_percentage</tt>:     This is relevant in pie chart only. It determines whether to display the values as
  #                             raw data, or as percentages of the whole pie.
  #                             The default is false.
  # <tt>font</tt>:              The font used for the value labels.
  #                             The default is Arial.
  # <tt>bold</tt>:              A boolean value that indicates whether the font is bold or not.
  #                             The default is true.
  # <tt>size</tt>:              The font's size.
  #                             The default font size is calculated based on the canvas size.
  # <tt>color</tt>:             The font's color. This must be a string holding triple hexadecimal values representing
  #                             the red, green, and blue components for a color.
  #                             The default is "000000" (black).
  # <tt>background_color</tt>:  This applies only when the above 'position' parameter is set to 'cursor'. It determines
  #                             the labels' background color. When omitted, value labels have no background. This must be
  #                             a string holding triple hexadecimal values representing the red, green, and blue
  #                             components for a color.
  #                             The default is omitted (no background).
  # <tt>alpha</tt>:             This affects the labels' transparency, only when the embedded font is used. Valid values
  #                             are 0 (fully transparent) to 100 (fully opaque).
  #                             The default is 100.
  #
  # See http://www.maani.us/xml_charts/index.php?menu=Reference&submenu=chart_value
  # for additional documentation, examples and futher detail.
  class ChartValue < Base  
    # Positions
    CENTER  = "center"
    ABOVE   = "above"
    BELOW   = "below"
    LEFT    = "left"
    RIGHT   = "right"
    TOP     = "top"
    BOTTOM  = "bottom"
    OUTSIDE = "outside"
    INSIDE  = "inside"
    CURSOR  = "cursor"
    HIDE    = "hide"
      
    has_attribute :prefix, :suffix, :decimals, :decimal_char, :separator, :position,
                  :hide_zero, :as_percentage, :font, :bold, :size, :color,
                  :background_color, :alpha                  
  end
end