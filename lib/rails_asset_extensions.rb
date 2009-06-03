module EnginesHelper 
  # Configuration and defaults
  
  mattr_accessor :autoload_assets
  self.autoload_assets = true
  
  mattr_accessor :plugin_assets_directory
  self.plugin_assets_directory = 'plugin_assets'

  module Assets
    extend self

    # Propagate the public folders
    def propagate
      return if !EnginesHelper.autoload_assets
      plugin_list.each do |plugin|
        FileUtils.mkdir_p "#{RAILS_ROOT}/public/#{EnginesHelper.plugin_assets_directory}/#{plugin}"
        Dir.glob("#{RAILS_ROOT}/vendor/plugins/#{plugin}/public/*").each do |asset_path|
          FileUtils.cp_r(asset_path, "#{RAILS_ROOT}/public/#{EnginesHelper.plugin_assets_directory}/#{plugin}/.", :preserve => true)
        end
      end
    end

    def update_sass_directories

      if check_for_sass

        unless Sass::Plugin.options[:template_location].is_a?(Hash)
          Sass::Plugin.options[:template_location] = {
          Sass::Plugin.options[:template_location] => Sass::Plugin.options[:template_location].gsub(/\/sass$/, '') }
        end

        Dir.glob("#{RAILS_ROOT}/public/#{EnginesHelper.plugin_assets_directory}/**/sass") do |sass_dir|
          Sass::Plugin.options[:template_location] =
            Sass::Plugin.options[:template_location].merge({
            sass_dir => sass_dir.gsub(/\/sass$/, '')
          })
        end

      end
    end

  private

    def plugin_list
      Dir.glob("#{RAILS_ROOT}/vendor/plugins/*").reject { |p| 
        !File.exist?("#{RAILS_ROOT}/vendor/plugins/#{File.basename(p)}/public") 
      }.map { |d| File.basename(d) }
    end

    def check_for_sass
      defined?(Sass) && Sass.version[:major]*10 + Sass.version[:minor] >= 21
    end

  end

 
end



#
# These helpers are right out of the original Engines plugin
#

module AssetHelpers
  def self.included(base) #:nodoc:
    base.class_eval do
      [:stylesheet_link_tag, :javascript_include_tag, :image_path, :image_tag].each do |m|
        alias_method_chain m, :engine_additions
      end
    end
  end

  # Adds plugin functionality to Rails' default stylesheet_link_tag method.
  def stylesheet_link_tag_with_engine_additions(*sources)
    stylesheet_link_tag_without_engine_additions(*AssetHelpers.pluginify_sources("stylesheets", *sources))
  end

  # Adds plugin functionality to Rails' default javascript_include_tag method.  
  def javascript_include_tag_with_engine_additions(*sources)
    javascript_include_tag_without_engine_additions(*AssetHelpers.pluginify_sources("javascripts", *sources))
  end

  #
  # Our modified image_path now takes a 'plugin' option, though it doesn't require it
  #

  # Adds plugin functionality to Rails' default image_path method.
  def image_path_with_engine_additions(source, options={})
    options.stringify_keys!
    source = AssetHelpers.plugin_asset_path(options["plugin"], "images", source) if options["plugin"]
    image_path_without_engine_additions(source)
  end

  # Adds plugin functionality to Rails' default image_tag method.
  def image_tag_with_engine_additions(source, options={})
    options.stringify_keys!
    if options["plugin"]
      source = AssetHelpers.plugin_asset_path(options["plugin"], "images", source)
      options.delete("plugin")
    end
    image_tag_without_engine_additions(source, options)
  end

  #
  # The following are methods on this module directly because of the weird-freaky way
  # Rails creates the helper instance that views actually get
  #

  # Convert sources to the paths for the given plugin, if any plugin option is given
  def self.pluginify_sources(type, *sources)
    options = sources.last.is_a?(Hash) ? sources.pop.stringify_keys : { }
    sources.map! { |s| plugin_asset_path(options["plugin"], type, s) } if options["plugin"]
    options.delete("plugin") # we don't want it appearing in the HTML
    sources << options # re-add options      
  end  

  # Returns the publicly-addressable relative URI for the given asset, type and plugin
  def self.plugin_asset_path(plugin_name, type, asset)
    #raise "No plugin called '#{plugin_name}' - please use the full name of a loaded plugin." if !File.exist?("#{RAILS_ROOT}/public/plugin_assets/#{plugin_name}/#{type}/#{asset}")
    "/plugin_assets/#{plugin_name}/#{type}/#{asset}"
  end
  
end

module ::ActionView::Helpers::AssetTagHelper
  if !self.included_modules.include? AssetHelpers
    include AssetHelpers
  end
end