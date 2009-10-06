# ------------------------------------------------------------------------------
# == Girder::Components::AxisTicks
#
# Describe the ticks configuration of the chart axis
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# ------------------------------------------------------------------------------
module Ziya::Components
  # Sets the tick marks on the chart axes.
  #
  # <tt>value_ticks</tt>:       A boolean value that indicates whether the ticks on the value axis are visible or not.
  #                             The default is false.
  # <tt>category_ticks</tt>:    A boolean value that indicates whether the ticks on the category axis are visible or not.
  #                             The default is true.
  # <tt>position</tt>:          A string that determines where on the axis to display the ticks. Valid values are "outside",
  #                             "inside", and "centered".
  #                             The default is "outside".
  # <tt>major_thickness</tt>:   The thickness of major ticks. Major ticks are those appearing with the axis labels.
  #                             The default is 2 pixels.
  # <tt>major_color</tt>:       The color of major ticks. This must be a string holding triple hexadecimal values representing
  #                             the red, green, and blue components for a color.
  #                             The default is "000000" (black).
  # <tt>minor_thickness</tt>:   The thickness of minor ticks. Minor ticks are those appearing between major ticks.
  #                             The default is 1 pixel.
  # <tt>minor_color</tt>:       The color of minor ticks. This must be a string holding triple hexadecimal values representing
  #                             the red, green, and blue components for a color.
  #                             The default is "000000" (black).
  # <tt>minor_count</tt>:       This applies to the value axis only. It sets the number of minor ticks between every 2 major ticks.
  #                             The default is 4. The category axis displays minor ticks only where its labels get skipped.
  #
  # See http://www.maani.us/xml_charts/index.php?menu=Reference&submenu=axis_ticks
  # for additional documentation, examples and futher detail.
  class AxisTicks < Base  
    has_attribute :value_ticks, :category_ticks, :position, :major_thickness,
                  :major_color, :minor_thickness, :minor_color, :minor_count                 
  end
end