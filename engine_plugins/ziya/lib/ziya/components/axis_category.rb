# -----------------------------------------------------------------------------
# == Girder::Components::AxisCategory
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  # Sets the label attributes for the category-axis.
  #
  # <tt>skip</tt>:          If this axis holds too many labels, the skip key allows skipping (hiding) some labels.
  #                         A zero value doesn't hide any labels. If the skip value is 1, then the first label is
  #                         displayed, the following label is skipped, and so on. If the skip value is 2, then the
  #                         first label is displayed, the following 2 are skipped, and so on. Another way to hide
  #                         labels is by passing empty strings to chart_data in place of category labels.
  #                         The default is zero.
  # <tt>font</tt>:          The font used in the category-axis. See the Fonts section below.
  #                         The default is Arial.
  # <tt>bold</tt>:          A boolean value that indicates whether the font is bold or not.
  #                         The default is true.
  # <tt>size</tt>:          The font's size.
  #                         The default font size is calculated based on the chart size.
  # <tt>color</tt>:         The font's color. This must be a string holding triple hexadecimal values representing
  #                         the red, green, and blue components for a color.
  #                         The default is "000000" (black).
  # <tt>alpha</tt>:         This affects the labels' transparency, only when the embedded font is used (see the Fonts
  #                         section below.) Valid values are 0 (fully transparent) to 100 (fully opaque).
  #                         The default is 90. To hide all labels in this axis, set the alpha to 0
  # <tt>orientation</tt>:   This affects the labels' orientation, only when the embedded font is used (see the Fonts
  #                         section below.) Valid values are horizontal, diagonal_up, diagonal_down, vertical_up, and
  #                         vertical_down. Polar charts also accept the value circular.
  #                         The default value is horizontal.
  # <tt>margin</tt>:        This applies to area, stacked area, and line charts only. It's a boolean value that
  #                         indicates whether to leave a margin on the left and right of the graph, or bump it against
  #                         the left and right chart borders.
  #                         The default is false (no margin.) In mixed charts, there's always a margin to algin area
  #                         and line charts with column charts.
  # <tt>min</tt>:           This applies to scatter charts only, when the category-axis is calculated like the value-axis.
  #                         This determines the minimum value to start this axis with.
  #                         The default is calculated from the chart's data.
  # <tt>max</tt>:           This applies to scatter charts only, when the category-axis is calculated like the value-axis.
  #                         This determines the maximum value to end this axis with.
  #                         The default is calculated from the chart's data.
  # <tt>steps</tt>:         This applies to scatter charts only, when the category-axis is calculated like the value-axis.
  #                         This determines the number of steps between the minimum and maximum values. If the minimum value
  #                         is negative, and the maximum value is positive, then 'steps' is the number of steps between zero
  #                         and the larger of max and absolute min.
  #                         The default is 4.
  # <tt>prefix</tt>:        This applies to scatter charts only, when the category-axis is calculated like the value-axis.
  #                         This determines the characters to add before the value numbers (example: $10).
  #                         The default is nothing.
  # <tt>suffix</tt>:        This applies to scatter charts only, when the category-axis is calculated like the value-axis.
  #                         This determines the characters to add after the value numbers (example: 10%).
  #                         The default is nothing.
  # <tt>decimals</tt>:      This applies to scatter charts only, when the category-axis is calculated like the value-axis.
  #                         This determines the number of decimal places to the right of the decimal point (example: 10.45).
  #                         The default is zero (no decimals).
  # <tt>decimal_char</tt>:  This applies to scatter charts only, when the category-axis is calculated like the value-axis.
  #                         This determines the character to use at the left of a decimal fraction (example: 1.5).
  #                         The default is '.' (dot or full stop).
  # <tt>separator</tt>:     This applies to scatter charts only, when the category-axis is calculated like the value-axis.
  #                         This determines the character to place between every group of thousands (example: 1,00,000).
  #                         The default is nothing.
  #
  # See http://www.maani.us/xml_charts/index.php?menu=Reference&submenu=axis_category
  # for additional documentation, examples and futher detail.
  class AxisCategory < Base    
    has_attribute :skip, :font, :bold, :size, :color, :alpha, :orientation,
                  :margin, :min, :max, :steps, :prefix, :suffix, :decimals,
                  :decimal_char, :separator
  end
end