require File.expand_path 'lib/acts_as_publishable', File.dirname(__FILE__)
ActiveRecord::Base.send(:include, Acts::As::Publishable)

