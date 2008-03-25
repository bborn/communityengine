# -----------------------------------------------------------------------------
# == SwfCharts::Components::SeriesGap
#
# Sets up the gap between bars/columns for bar and column charts.
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  # Applies to column and bar charts only, and sets the gap between bars and sets of bars.
  #
  # <tt></tt>:
  #
  # See http://www.maani.us/xml_charts/index.php?menu=Reference&submenu=series_gap
  # for additional documentation, examples and futher detail.
  class SeriesGap < Base  
    has_attribute :bar_gap, :set_gap
  end
end