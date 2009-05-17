class PublishingGenerator < Rails::Generator::Base

  attr_reader :publishing_class
  attr_reader :publishing_table_name

  def initialize(args, options = {})
    klass = args.last

    begin; valid_klass = klass.camelcase.constantize; rescue; end

    if valid_klass
      @publishing_table_name = klass.to_s.downcase.pluralize
      @publishing_class = klass.to_s.capitalize
    else
      raise "#{klass} is not a valid class in this application."
    end
  
    super
  end

  def manifest
    record do |m|
      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate',
          :migration_file_name => "add_published_as_to_#{@publishing_table_name}"
      end
    end
  end

  protected
  def usage
    puts "Usage: #{$0} publishing [ModelName]"
  end
end
