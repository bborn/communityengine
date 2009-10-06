# Include hook code here
require 'acts_as_commentable'
ActiveRecord::Base.send(:include, Juixe::Acts::Commentable)
