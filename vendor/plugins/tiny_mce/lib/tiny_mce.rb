# Require all the necessary files to run TinyMCE
require 'tiny_mce/base'
require 'tiny_mce/exceptions'
require 'tiny_mce/configuration'
require 'tiny_mce/spell_checker'
require 'tiny_mce/helpers'

module TinyMCE
  def self.initialize
    return if @intialized
    raise "ActionController is not available yet." unless defined?(ActionController)
    ActionController::Base.send(:include, TinyMCE::Base)
    ActionController::Base.send(:helper, TinyMCE::Helpers)
    @intialized = true
  end
end

TinyMCE.initialize
