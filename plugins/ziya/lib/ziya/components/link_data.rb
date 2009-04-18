# -----------------------------------------------------------------------------
# == Girder::Components::LinkData
#
# Sets up a handler for clickable chart elements
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  # Sets the URL of a script responsible for processing clicks on chart elements.
  # This enables drilling down into charts.
  #
  # <tt></tt>:
  #
  # See http://www.maani.us/xml_charts/index.php?menu=Reference&submenu=link_data
  # for additional documentation, examples and futher detail.
  class LinkData < Base  
    has_attribute :url, :target
  end
end