module Professionalnerd #:nodoc:
  module SimplePrivateMessages #:nodoc:
    module HasPrivateMessagesExtensions #:nodoc:
      def self.included(base) #:nodoc:
        base.extend ActMethods
      end 

      module ActMethods
        # Sets up a model have private messages, defining the child class as specified in :class_name (typically "Messages").
        # Provided the following instance messages:
        # *  <tt>sent_messages</tt> - returns a collection of messages for which this object is the sender.
        # *  <tt>received_messages</tt> - returns a collection of messages for which this object is the recipient.
        def has_private_messages(options = {})
          options[:class_name] ||= 'Message'
          
          unless included_modules.include? InstanceMethods
            class_inheritable_accessor :options
            has_many :sent_messages,
                     :class_name => options[:class_name],
                     :foreign_key => 'sender_id',
                     :order => "created_at DESC",
                     :conditions => ["sender_deleted = ?", false],
                     :dependent => :destroy

            has_many :received_messages,
                     :class_name => options[:class_name],
                     :foreign_key => 'recipient_id',
                     :order => "created_at DESC",
                     :conditions => ["recipient_deleted = ?", false],
                     :dependent => :destroy                     

            extend ClassMethods 
            include InstanceMethods 
          end 
          self.options = options
        end 
      end 

      module ClassMethods #:nodoc:
        # None yet...
      end

      module InstanceMethods
        # Returns true or false based on if this user has any unread messages
        def unread_messages?
          unread_message_count > 0 ? true : false
        end
        
        # Returns the number of unread messages for this user
        def unread_message_count
          eval options[:class_name] + '.count(:conditions => ["recipient_id = ? AND recipient_deleted = ? AND read_at IS NULL", self, false])'
        end
      end 
    end
  end
end 
