# -----------------------------------------------------------------------------
# == Girder::Components::Image
#
# Draw an image on a chart. Can also be used to reference another chart and 
# embed it in the current chart. (See XML/SWF docs for composite charts )
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  class Image < Base  
    has_attribute :layer, :transition, :delay, :duration, :url, :x, :y, :width,
                  :height, :rotation, :alpha
  end
end