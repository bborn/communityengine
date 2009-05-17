# -----------------------------------------------------------------------------
# == Girder::Components::ChartPreference
#
# Sets up various preferences available on a given chart type
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  # Sets the preferences for some chart types. Each chart type has different preferences,
  # or no preferences at all.
  #
  # <tt></tt>:
  #
  # See http://www.maani.us/xml_charts/index.php?menu=Reference&submenu=chart_pref
  # for additional documentation, examples and futher detail.
  class ChartPref < Base  
    has_attribute :point_shape, :fill_shape, :reverse, :type, :line_thickness,
                  :bull_color, :bear_color, :point_size, :point_shape,
                  :trend_thickness, :trend_alpha, :line_alpha, :rotation_x,
                  :rotation_y, :grid             
  end
end