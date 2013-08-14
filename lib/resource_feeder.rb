require 'resource_feeder/rss'
require 'resource_feeder/atom'
ActionController::Base.send(:include, ResourceFeeder::Rss, ResourceFeeder::Atom)
