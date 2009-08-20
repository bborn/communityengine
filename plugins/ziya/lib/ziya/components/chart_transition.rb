# -----------------------------------------------------------------------------
# == Girder::Components::ChartTransition
#
# Sets up a transition when the chart first renders
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  # Sets the transition attributes for the chart elements.
  #
  # <tt>type</tt>:      The type of the transition. Valid values are dissolve, drop, spin, scale, zoom,
  #                     blink, slide_right, slide_left, slide_up, slide_down, and none.
  #                     The default is none, which draws the chart immediately without a transition.
  # <tt>delay</tt>:     The delay in seconds before starting the transition.
  #                     The default is zero.
  # <tt>duration</tt>:  The transition's duration in seconds.
  #                     The default is 1.
  # <tt>order</tt>:     The order in which to transition the chart's parts. Valid values are series,
  #                     category, and all.
  #                     The default is all.
  #
  # See http://www.maani.us/xml_charts/index.php?menu=Reference&submenu=chart_trasition
  # for additional documentation, examples and futher detail.
  class ChartTransition < Base      
    # Transition order
    SERIES   = "series"
    CATEGORY = "category"
    ALL      = "all"
  
    has_attribute :type, :delay, :duration, :order                  
  end
end