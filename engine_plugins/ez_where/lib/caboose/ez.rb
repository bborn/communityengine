
module Caboose

  module EZ
    #
    # EZ::Condition plugin for generating the :conditions where clause
    # for ActiveRecord::Base.find. And an extension to ActiveRecord::Base
    # called AR::Base.find_with_conditions that takes a block and builds
    # the where clause dynamically for you.
    #
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods      
      # The block recieves the condition for the model itself, as well as for any :include associated model:
      # Model.ez_find( :all, :include => [:attachments, :readers]) do |model, attachment, reader|
      #  model.title =~ '%article%'
      #  attachment.type = 'image/png' 
      #  reader.id = 2
      # end
      def ez_find(what, *args, &block)
        options = args.last.is_a?(Hash) ? args.last : {}
        options[:include] ||= []; options[:include] = [options[:include]] if options[:include].kind_of?(Symbol)
        outer_mapping = options.delete(:outer) || {} # preset :outer value for each :include subcondition, defaults to :and
        outer_mapping.default = :and
        inner_mapping = options.delete(:inner) || {} # preset :inner value for each :include subcondition, defaults to :and
        inner_mapping.default = :and
        if block_given?
          klass = self.name.downcase.to_sym       
          conditions = [ez_condition(:outer => outer_mapping[klass], :inner => inner_mapping[klass])] # conditions on self first          
          options[:include].uniq.each do |assoc| 
            assoc_klass = reflect_on_association(assoc).klass
            cond_options = {}
            cond_options[:outer] = outer_mapping[assoc]
            cond_options[:inner] = inner_mapping[assoc]
            conditions << assoc_klass.ez_condition(cond_options)
          end
          yield *conditions
          condition = Caboose::EZ::Condition.new
          condition << options[:conditions] || []
          conditions.each { |c| condition << c }
          options[:conditions] = condition.to_sql
          # p options[:conditions] if $DEBUG
        end
        self.find(what, options)
      end
      
      alias :find_with_conditions :ez_find
      alias :find_with_block :ez_find
      
      # Returns model specific (table_name prefixed) Condition
      def ez_condition(*args, &block)
        options = args.last.is_a?(Hash) ? args.last : {}
        options[:table_name] ||= table_name
        Condition.new(options, &block)
      end     
    end

  end # EZ module

end # Caboose module