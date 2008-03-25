# -----------------------------------------------------------------------------
# == Girder::Components::LegendTransition
#
# Sets up transition on the chart legends when chart first displays
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  # Sets the transition attributes for the legend.
  #
  # <tt></tt>:
  #
  # See http://www.maani.us/xml_charts/index.php?menu=Reference&submenu=legend_transition
  # for additional documentation, examples and futher detail.
  class LegendTransition < Base  
    has_attribute :type, :delay, :duration
  end
end