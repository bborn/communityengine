# -----------------------------------------------------------------------------
# == Girder::Components::AxisValue
#
# Setup configuration on the chart value axis
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  # Sets the label attributes for the value-axis.
  #
  # <tt>min</tt>:               The minimum value to start the value-axis with.
  #                             The default is calculated from the chart's data. In 3D column charts, the minimum value
  #                             is always zero.
  # <tt>max</tt>:               The maximum value to end the value-axis with.
  #                             The default is calculated from the chart's data.
  # <tt>steps</tt>:             The number of steps between the minimum and maximum values. If the minimum value is negative,
  #                             and the maximum value is positive, then 'steps' is the number of steps between zero and the
  #                             larger of max and absolute min.
  #                             The default is 4.
  # <tt>prefix</tt>:            The characters to add before the value numbers (example: $10).
  #                             The default is nothing.
  # <tt>suffix</tt>:            The characters to add after the value numbers (example: 10%).
  #                             The default is nothing.
  # <tt>decimals</tt>:          The number of decimal places to the right of the decimal point (example: 10.45).
  #                             The default is zero (no decimals).
  # <tt>decimal_char</tt>:      The character to use at the left of a decimal fraction (example: 1.5).
  #                             The default is '.' (dot or full stop.)
  # <tt>separator</tt>:         The character to place between every group of thousands (example: 1,00,000).
  #                             The default is nothing.
  # <tt>show_min</tt>:          A boolean that indicates whether show or hide the first label in the value-axis. Hiding this
  #                             first label might be necessary if it overlaps with the first label in the category axis.
  #                             The default is true (show the first label).
  # <tt>font</tt>:              The font used in the value-axis.
  #                             The default is Arial.
  # <tt>bold</tt>:              A boolean value that indicates whether the font is bold or not.
  #                             The default is true.
  # <tt>size</tt>:              The font's size.
  #                             The default font size is calculated based on the chart size.
  # <tt>color</tt>:             The font's color. This must be a string holding triple hexadecimal values representing the red,
  #                             green, and blue components for a color.
  #                             The default is "000000" (black).
  # <tt>background_color</tt>:  This applies to Polar charts only. It determines the labels' background color to make them visible
  #                             over the graph. When omitted, axis_value labels have no background. This must be a string holding
  #                             triple hexadecimal values representing the red, green, and blue components for a color.
  #                             The default is omitted (no background).
  # <tt>alpha</tt>:             This affects the labels' transparency, only when the embedded font is used. Valid values are
  #                             0 (fully transparent) to 100 (fully opaque).
  #                             The default is 90. To hide all labels in this axis, set the alpha to 0.
  # <tt>orientation</tt>:       This affects the labels' orientation, only when the embedded font is used. Valid values are
  #                             "horizontal", "diagonal_up", "diagonal_down", "vertical_up", and "vertical_down."
  #                             The default value is "horizontal".
  #
  # See http://www.maani.us/xml_charts/index.php?menu=Reference&submenu=axis_value
  # for additional documentation, examples and futher detail.
  class AxisValue < Base  
    has_attribute :min, :max, :steps, :prefix, :suffix, :decimals,
                  :decimal_char, :separator, :show_min, :font, :bold,
                  :size, :color, :background_color, :alpha, :orientation                
  end
end