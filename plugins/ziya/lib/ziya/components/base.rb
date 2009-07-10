require 'yaml'

# -----------------------------------------------------------------------------
# == Girder::Components::Base
#
# Abstract class representing the base class for all chart preferences
# TODO Not getting parents inherited properties if defined as defaults
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  class Base    
    include Ziya::Utils::Text
    
    # Default Colors
    WHITE = "ffffff"
    BLACK = "000000"
  
    # Default orientations
    HORIZONTAL    = "horizontal"
    DIAGONAL_UP   = "diagonal_up"
    DIAGONAL_DOWN = "diagonal_down"
    VERTICAL_UP   = "vertical_up"
    VERTICAL_DOWN = "vertical_down"
    CIRCULAR      = "circular"    

    # Grid lines
    SOLID  = "solid"
    DOTTED = "dotted"
    DASHED = "dashed"
  
    # Transition types
    DISSOLVE    = "dissolve"
    DROP        = "drop"
    SPIN        = "spin"
    SCALE       = "scale"
    ZOOM        = "zoom"
    BLINK       = "blink"
    SLIDE_RIGHT = "slide_right"
    SLIDE_LEFT  = "slide_left"
    SLIDE_UP    = "slide_up"
    SLIDE_DOWN  = "slide_down"
    NONE        = "none"

    @@attributes = {}

    class << self
      def has_attribute(*args)
        args.each do |attribute|
          # Determine the attribute name from the hash or symbol that was passed in and set the default value
          attribute_name   = attribute.is_a?(Hash) ? attribute.keys.first.to_s   : attribute.to_s
          attribute_value  = attribute.is_a?(Hash) ? attribute.values.first.to_s : nil

          # Add the attribute to the collection making sure to create a new array if one doesn't exist
          if @@attributes[self.to_s].nil?
            @@attributes[self.to_s]  = [{attribute_name => attribute_value}]
          else
            @@attributes[self.to_s] << {attribute_name => attribute_value}
          end

          # Create the accessor methods for the attribute
          unless self.instance_methods.include?(attribute_name) && self.instance_methods.include?("#{attribute_name}=")
            self.module_eval "attr_accessor :#{attribute_name}"
          end
        end
      end
    
      # -------------------------------------------------------------------------
      # Retrieve class level preferences
      def attributes
        @@attributes
      end
    end
  
    # -------------------------------------------------------------------------
    # Merge preferences.
    def merge(parent_attributes, force=false)
      attributes = @@attributes[self.class.name] || []
      attributes.each do |p|
        unless parent_attributes.send(p.keys.first.to_sym).nil?
          send("#{p.keys.first.to_sym}=", parent_attributes.send(p.keys.first.to_sym)) 
        end
      end
    end
  
    # -------------------------------------------------------------------------
    # Handles simple flatten operation
    def method_missing(method, *args)
      case method
        when :flatten
          xml   = args.first
          clazz = self.class.name.gsub!( /Ziya::Components::/, '' )
          pref  = underscore( clazz )
          self.class.module_eval "xml.#{pref}( #{options_as_string} )"
        else
          super.method_missing(method, *args)
      end
    end
  
    # -------------------------------------------------------------------------
    # Turns preferences in a hash of key value pairs
    def options
      options = {}
      @@attributes[self.class.name].each do |p|
        options[p] = send(p.keys.first) unless send(p.keys.first).to_s.empty?
      end
      options
    end
    
    # -------------------------------------------------------------------------
    # Turns options hash into string representation
    def options_as_string
      buff = ""
      options.each_pair do |k,v|
        buff << (buff.size == 0 ? ":#{k} => '#{v}'" : ",:#{k} => '#{v}'") unless v.nil?
      end
      buff
    end
  end
end