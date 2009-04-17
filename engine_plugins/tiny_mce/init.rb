require 'tiny_mce'
TinyMCE::OptionValidator.load
ActionController::Base.send(:include, TinyMCE)
ActionView::Base.send :include, TinyMCEHelper