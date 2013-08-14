require 'activity_tracker/activity'
require 'activity_tracker/activity_tracker'
ActiveRecord::Base.send(:include, ActivityTracker)