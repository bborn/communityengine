$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'test/unit'
RAILS_ENV = "test"
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require 'action_controller/test_process'
require 'action_controller/resources'
require 'breakpoint'
