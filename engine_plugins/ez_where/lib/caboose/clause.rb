module Caboose

  module EZ
    # EZ::Condition plugin for generating the :conditions where clause
    # for ActiveRecord::Base.find. And an extension to ActiveRecord::Base
    # called AR::Base.find_with_conditions that takes a block and builds
    # the where clause dynamically for you.
    
    class AbstractClause
      
      attr_reader :test
      attr_accessor :outer
      attr_accessor :case_insensitive
      
      def to_sql; nil; end
      
      def case_insensitive
        @case_insensitive = true
        self
      end

      alias :downcase :case_insensitive
      alias :upcase :case_insensitive
      alias :nocase :case_insensitive
            
      def empty?
        true
      end
      
    end
    
    class Clause < AbstractClause
      # need this so that id doesn't call Object#id
      # left it open to add more methods that
      # conflict when I find them
      [:id, :type].each { |m| undef_method m }
      
      attr_reader :name, :test, :value
      
      # Initialize a Clause object with the name of the
      # column.    
      def initialize(*args)
        @table_prefix = ''
        @negate = false
        @case_insensitive = false
        case args.length
        when 0:
          raise 'Expected at least one parameter'
        when 1:
          @name = args.first.to_s
        when 2:
          @table_prefix = args[0].to_s + '.' unless args[0].to_s.empty? 
          @name = args[1].to_s
        when 3:
          @table_prefix = args[0].to_s + '.' unless args[0].to_s.empty? 
          @name = args[1].to_s
          @negate = args[2]
        end
        # append ! to negate the statement
        if @name[-1].chr == '!'
          @negate = true
          @name = @name.slice(0, @name.length - 1) 
        end
        # prefix with esc_ to avoid clashes with standard methods like 'alias'
        @name = @name.slice(4, @name.length) if @name =~ /^esc_.*/
      end
    
      # The == operator has been over-ridden here to
      # stand in for an exact match ["foo = ?", "bar"]
      def ==(other)
        @test = :equals
        @value = (other.kind_of?(Symbol) and other != :null) ? other.to_s : other
      end
    
      # The =~ operator has been over-ridden here to
      # stand in for the sql LIKE "%foobar%" clause.
      def =~(pattern)
        @test = :like
        @value = pattern
      end
      
      # The % operator has been over-ridden here to
      # stand in for the sql SOUNDS LIKE "%foobar%" clause.
      # This isn't always supported on all RDMSes.
      def %(string)
        @test = :soundex
        @value = string
      end
      
      # The spaceship <=> operator has been over-ridden here to
      # stand in for the sql ["BETWEEN ? AND ?", 1, 5] "%foobar%" clause.
      def <=>(range)
        @test = :between
        @value = range
      end
    
      # The === operator has been over-ridden here to
      # stand in for the sql ["IN (?)", [1,2,3]] clause.
      def ===(range)
        @test = :in
        @value = range
      end
    
      # switch on @test and build appropriate clause to 
      # match the operation.
      def to_sql
        return nil if empty?
        case @test
        when :equals
          if @value == :null
            @negate ? ["#{@table_prefix}#{@name} IS NOT NULL"] : ["#{@table_prefix}#{@name} IS NULL"] 
          else
            if @case_insensitive and @value.respond_to?(:upcase)
              @negate ? ["UPPER(#{@table_prefix}#{@name}) != ?", @value.upcase] : ["UPPER(#{@table_prefix}#{@name}) = ?", @value.upcase] 
            else
              @negate ? ["#{@table_prefix}#{@name} != ?", @value] : ["#{@table_prefix}#{@name} = ?", @value] 
            end
          end 
        when :like
          if @case_insensitive and @value.respond_to?(:upcase)
            @negate ? ["UPPER(#{@table_prefix}#{@name}) NOT LIKE ?", @value.upcase] : ["UPPER(#{@table_prefix}#{@name}) LIKE ?", @value.upcase]
          else
            @negate ? ["#{@table_prefix}#{@name} NOT LIKE ?", @value] : ["#{@table_prefix}#{@name} LIKE ?", @value]
          end
        when :soundex
          ["#{@table_prefix}#{@name} SOUNDS LIKE ?", @value]
        when :between
          @negate ? ["#{@table_prefix}#{@name} NOT BETWEEN ? AND ?", [@value.first, @value.last]] : ["#{@table_prefix}#{@name} BETWEEN ? AND ?", [@value.first, @value.last]] 
        when :in
          @negate ? ["#{@table_prefix}#{@name} NOT IN (?)", @value.to_a] : ["#{@table_prefix}#{@name} IN (?)", @value.to_a] 
        else
          ["#{@table_prefix}#{@name} #{@test} ?", @value]
        end
      end
    
      # If a clause is empty it won't be added to the condition at all
      def empty?
        (@value.to_s.empty? or (@test == :like and @value.to_s =~ /^([%]+)$/))
      end
    
      # This method_missing takes care of setting
      # @test to any operator thats not covered 
      # above. And @value to the value
      def method_missing(name, *args)
        @test = name
        @value = args.first
      end
    end
    
    class ArrayClause < AbstractClause
      
      # wraps around an Array in ActiveRecord format ['column = ?', 2]
      
      def initialize(cond_array)
        @test = :array
        @cond_array = cond_array
      end
            
      def to_sql
        return nil if empty?
        query = (@cond_array.first =~ /^\([^\(\)]+\)$/) ? "#{@cond_array.first}" : "(#{@cond_array.first})"
        [query, values]
      end
   
      def values
        @cond_array[1..@cond_array.length].select { |value| !value.to_s.empty? }
      end
    
      def empty?
        return false if @cond_array.first.to_s =~ /NULL/i
        (@cond_array.first.to_s.empty? || (@cond_array.first.to_s =~ /\?/ and values.empty?))
      end
      
    end
    
    class SqlClause < AbstractClause
      
      # wraps around a raw SQL string
      
      def initialize(sql)
        @test = :sql
        @sql = sql
      end
      
      def to_sql
        return nil if empty?
        [@sql]
      end
      
      def empty?
        @sql.to_s.empty?
      end
      
    end
    
    class MultiClause < AbstractClause
      
      # wraps around a multiple column clause
      
      [:==, :===, :=~].each { |m| undef_method m }
      
      def initialize(names, table_name = nil, inner = :or)
        @test = :multi 
        @operator = :==
        @value = nil
        @names, @table_name, @inner, = names, table_name, inner
      end
      
      def method_missing(operator, *args)
        if [:<, :>, :<=, :>=, :==, :===, :=~, :%, :<=>].include?(operator)
          @operator = operator
          @value = args.first
        end
      end
      
      def to_sql
        return nil if empty?
        cond = Caboose::EZ::Condition.new :table_name => @table_name, :inner => @inner, :parenthesis => true
        @names.each { |name| cond.create_clause(name, @operator, @value, @case_insensitive) }     
        return cond.to_sql
      end
      
      def empty?
        (@value.to_s.empty? or @names.empty? or @value.to_s =~ /^([%]+)$/)
      end
            
    end
    
  end # EZ
      
end # Caboose    