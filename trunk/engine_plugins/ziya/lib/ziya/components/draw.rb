# -----------------------------------------------------------------------------
# == Girder::Components::Draw
#
# Sets up a drawing area on the chart to draw text, rect, circles...
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  # Holds any number of elements to draw. A draw element can be a circle, image (JPEG or SWF),
  # line, rectangle, or text. Use draw "image" to include SWF flash file with animation,
  # roll-over buttons, sounds, scripts, etc.
  #
  # <tt></tt>:
  #
  # See http://www.maani.us/xml_charts/index.php?menu=Reference&submenu=draw
  # for additional documentation, examples and futher detail.
  class Draw < Base  
    has_attribute :components
                     
    # -------------------------------------------------------------------------
    # Dump has_attribute into xml element
    def flatten( xml )
      unless components.nil?
        xml.draw do 
          components.each { |c| c.flatten( xml ) }
        end
      end
    end
  end
end