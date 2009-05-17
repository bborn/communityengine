# -----------------------------------------------------------------------------
# == Ziya::Components::SeriesColor
#
# Sets up chart elements color
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  # Sets the colors to use for the chart series.
  #
  # <tt></tt>:
  #
  # See http://www.maani.us/xml_charts/index.php?menu=Reference&submenu=series_color
  # for additional documentation, examples and futher detail.
  class SeriesColor < Base    
    has_attribute :colors
  
    # -------------------------------------------------------------------------
    # Dump has_attribute into xml element    
    def flatten( xml )
      unless colors.nil? or colors.empty?
        xml.series_color do
          cols = colors.split( "," )
          cols.each { |c| xml.color( c ) }
        end   
      end
    end
  end
end