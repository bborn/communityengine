class PrivateMessageScaffoldGenerator < Rails::Generator::NamedBase
  
  attr_reader :singular_camel_case_name, :plural_camel_case_name, :singular_lower_case_name, :plural_lower_case_name
  attr_reader :singular_camel_case_parent, :plural_camel_case_parent, :singular_lower_case_parent, :plural_lower_case_parent

  def initialize(runtime_args, runtime_options = {})
    super
    
    @singular_camel_case_name = @name.singularize.camelize
    @plural_camel_case_name = @name.pluralize.camelize
    @singular_lower_case_name = @name.singularize.underscore
    @plural_lower_case_name = @name.pluralize.underscore

    @parent_name = args.shift || 'User'
    @singular_camel_case_parent = @parent_name.singularize.camelize
    @plural_camel_case_parent = @parent_name.pluralize.camelize
    @singular_lower_case_parent = @parent_name.singularize.underscore
    @plural_lower_case_parent = @parent_name.pluralize.underscore    
  end
  
  def manifest
    record do |m|
      m.directory "app/controllers"
      m.template "controller.rb", "app/controllers/#{@plural_lower_case_name}_controller.rb"

      m.directory "app/views"
      m.directory "app/views/#{@plural_lower_case_name}"
      m.template "view_index.html.erb", "app/views/#{@plural_lower_case_name}/index.html.erb"
      m.template "view_index_inbox.html.erb", "app/views/#{@plural_lower_case_name}/_inbox.html.erb"
      m.template "view_index_sent.html.erb", "app/views/#{@plural_lower_case_name}/_sent.html.erb"
      m.template "view_show.html.erb", "app/views/#{@plural_lower_case_name}/show.html.erb"
      m.template "view_new.html.erb", "app/views/#{@plural_lower_case_name}/new.html.erb"
    end
  end
end
