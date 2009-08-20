# -----------------------------------------------------------------------------
# == Girder::Components::LegendLabel
#
# Sets up chart legend configuration
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  # Sets the legend's label attributes.
  #
  # <tt></tt>:
  #
  # See http://www.maani.us/xml_charts/index.php?menu=Reference&submenu=legend_label
  # for additional documentation, examples and futher detail.
  class LegendLabel < Base  
    SQUARE = "square"
    CIRCLE = "circle"
    LINE   = "line"
  
    has_attribute :layout, :bullet, :font, :bold, :size, :color, :alpha
  end
end