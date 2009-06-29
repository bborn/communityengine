# -----------------------------------------------------------------------------
# == SwfCharts::Components::ChartBorder
#
# Sets up whether to switch colors for each element in a serie. Only applies
# to chart with only one serie
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  # Switches the series colors to be used for the categories instead.
  #
  # <tt></tt>:
  #
  # See http://www.maani.us/xml_charts/index.php?menu=Reference&submenu=series_switch
  # for additional documentation, examples and futher detail.
  class SeriesSwitch < Base  
    has_attribute :switch
    
    # -------------------------------------------------------------------------
    # Dump has_attribute into xml element    
    def flatten( xml )
      xml.series_switch( switch )
    end
  end
end