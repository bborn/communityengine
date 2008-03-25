module Ziya; end

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'builder'

require 'ziya/utils'
require 'ziya/components'
require 'ziya/charts'