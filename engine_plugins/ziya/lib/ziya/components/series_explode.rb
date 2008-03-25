# -----------------------------------------------------------------------------
# == SwfCharts::Components::ChartExplode
#
# Sets up the 'exploding' factor on a particular chart. Only applies to pie,
# scattered and line charts.
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  # Applies to pie, line, and scatter charts only. In pie charts, it sets which pie wedge
  # separates from the pie for emphasis. In line and scatter charts, it sets which line or
  # point is increased in thickness or size for emphasis.
  #
  # <tt></tt>:
  #
  # See http://www.maani.us/xml_charts/index.php?menu=Reference&submenu=series_explode
  # for additional documentation, examples and futher detail.
  class SeriesExplode < Base    
    has_attribute :numbers
  
    # -------------------------------------------------------------------------
    # Dump has_attribute into xml element    
    def flatten( xml )
      unless numbers.nil?
        xml.series_explode do
          if numbers.respond_to? :each
            numbers.each { |n| xml.number( n ) }
          else
            xml.number( numbers )
          end
        end   
      end
    end
  end
end