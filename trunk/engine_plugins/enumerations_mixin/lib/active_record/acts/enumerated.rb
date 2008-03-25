# Copyright (c) 2005 Trevor Squires
# Released under the MIT License.  See the LICENSE file for more details.

module ActiveRecord
  module Acts 
    module Enumerated 
      def self.append_features(base)
        super        
        base.extend(MacroMethods)              
      end
      
      module MacroMethods          
        def acts_as_enumerated(options = {})
          valid_keys = [:conditions, :order, :on_lookup_failure]
          options.assert_valid_keys(*valid_keys)
          valid_keys.each do |key|   
            write_inheritable_attribute("acts_enumerated_#{key.to_s}".to_sym, options[key]) if options.has_key? key
          end
          
          unless self.is_a? ActiveRecord::Acts::Enumerated::ClassMethods
            extend ActiveRecord::Acts::Enumerated::ClassMethods
            class_eval do
              include ActiveRecord::Acts::Enumerated::InstanceMethods
              validates_uniqueness_of :name
              before_save :enumeration_model_update
              before_destroy :enumeration_model_update
            end
          end
        end
      end
      
      module ClassMethods  
        attr_accessor :enumeration_model_updates_permitted
        
        def all
          return @all if @all
          @all = find(:all, 
                      :conditions => read_inheritable_attribute(:acts_enumerated_conditions),
                      :order => read_inheritable_attribute(:acts_enumerated_order)
                      ).collect{|val| val.freeze}.freeze
        end

        def [](arg)
          case arg
          when Symbol
            rval = lookup_name(arg.id2name) and return rval
          when String
            rval = lookup_name(arg) and return rval
          when Fixnum
            rval = lookup_id(arg) and return rval
          when nil
            rval = nil 
          else
            raise TypeError, "#{self.name}[]: argument should be a String, Symbol or Fixnum but got a: #{arg.class.name}"            
          end
          self.send((read_inheritable_attribute(:acts_enumerated_on_lookup_failure) || :enforce_strict_literals), arg)
        end

        def lookup_id(arg)
          all_by_id[arg]
        end

        def lookup_name(arg)
          all_by_name[arg]
        end
                                   
        def include?(arg)
          case arg
          when Symbol
            return !lookup_name(arg.id2name).nil?
          when String
            return !lookup_name(arg).nil?
          when Fixnum
            return !lookup_id(arg).nil?
          when self
            possible_match = lookup_id(arg.id) 
            return !possible_match.nil? && possible_match == arg
          end
          return false
        end

        # NOTE: purging the cache is sort of pointless because
        # of the per-process rails model.  
        # By default this blows up noisily just in case you try to be more 
        # clever than rails allows.  
        # For those times (like in Migrations) when you really do want to 
        # alter the records you can silence the carping by setting
        # enumeration_model_updates_permitted to true.
        def purge_enumerations_cache
          unless self.enumeration_model_updates_permitted
            raise "#{self.name}: cache purging disabled for your protection"
          end
          @all = @all_by_name = @all_by_id = nil
        end

        private 
        
        def all_by_id 
          return @all_by_id if @all_by_id
          @all_by_id = all.inject({}) { |memo, item| memo[item.id] = item; memo;}.freeze              
        end
        
        def all_by_name
          return @all_by_name if @all_by_name
          begin
            @all_by_name = all.inject({}) { |memo, item| memo[item.name] = item; memo;}.freeze              
          rescue NoMethodError => err
            if err.name == :name
              raise TypeError, "#{self.name}: you need to define a 'name' column in the table '#{table_name}'"
            end
            raise
          end            
        end   
        
        def enforce_none(arg)
          return nil
        end

        def enforce_strict(arg)
          raise ActiveRecord::RecordNotFound, "Couldn't find a #{self.name} identified by (#{arg.inspect})"
        end

        def enforce_strict_literals(arg)
          if Fixnum === arg || Symbol === arg
            raise ActiveRecord::RecordNotFound, "Couldn't find a #{self.name} identified by (#{arg.inspect})"
          end
          return nil
        end
        
      end

      module InstanceMethods
        def ===(arg)
          case arg
          when Symbol, String, Fixnum, nil
            return self == self.class[arg]
          when Array
            return self.in?(*arg)
          end
          super
        end
        
        alias_method :like?, :===
        
        def in?(*list)
          for item in list
            self === item and return true
          end
          return false
        end

        def name_sym
          self.name.to_sym
        end

        private

        # NOTE: updating the models that back an acts_as_enumerated is 
        # rather dangerous because of rails' per-process model.
        # The cached values could get out of synch between processes
        # and rather than completely disallow changes I make you jump 
        # through an extra hoop just in case you're defining your enumeration 
        # values in Migrations.  I.e. set enumeration_model_updates_permitted = true
        def enumeration_model_update
          if self.class.enumeration_model_updates_permitted    
            self.class.purge_enumerations_cache
            return true
          end
          # Ugh.  This just seems hack-ish.  I wonder if there's a better way.
          self.errors.add('name', "changes to acts_as_enumeration model instances are not permitted")   
          return false
        end
      end
    end
  end
end
        
