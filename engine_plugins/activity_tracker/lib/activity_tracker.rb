module ActivityTracker # :nodoc:

  def self.included(base) # :nodoc:
    base.extend ActMethods
  end
  
  module ActMethods

    # Arguments: 
    #   <tt>:actor</tt> - the user model that owns this object. In most cases this will be :user. Required.
    #   <tt>:options</tt> - hash of options.
    #
    #
    # Options:
    #   <tt>:if</tt> - a Proc that determines if the activity should be tracked.
    #
    # Examples:
    #   acts_as_activity :user
    #   acts_as_activity :author
    #   acts_as_activity :user, :if => Proc.new{|record| record.post.length > 100 } - will only track the activity if the length of the post is more than 100
    def acts_as_activity(actor, options = {})
      unless included_modules.include? InstanceMethods
        after_create do |record|
          unless options[:if] and not evaluate_condition(options[:if], record)
            record.create_activity_from_self 
          end
        end

        class_inheritable_accessor :activity_options
        include InstanceMethods
      end      
      self.activity_options = {:actor => actor}
    end
    
    # This adds a helper method to the model which makes it easy to track actions that can't be associated with an object in the database.
    # Options:
    #   <tt>:actions</tt> - An array of actions that are accepted to be tracked.
    #
    # Examples: 
    #   tracks_unlinked_activities [:logged_in, :invited_friends] - class.track_activity(:logged_in)
    #
    def tracks_unlinked_activities(actions = [])
      unless included_modules.include? InstanceMethods
        class_inheritable_accessor :activity_options
        include InstanceMethods
      end
      self.activity_options = {:actions => actions}    
    end
        
  end

  module InstanceMethods

    def create_activity_from_self
      activity = Activity.new
      activity.item = self
      activity.action = Inflector::underscore(self.class)
      actor_id = self.send( activity_options[:actor].to_s + "_id" )
      activity.user_id = actor_id
      activity.save
    end

    def track_activity(action)
      if activity_options[:actions].include?(action)
        activity = Activity.new
        activity.action = action.to_s
        activity.user_id = self.id
        activity.save!
      else
        raise "The action #{action} can't be tracked."
      end
    end    

    
  end


end