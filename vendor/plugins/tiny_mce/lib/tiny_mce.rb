# Require all the necessary files to run TinyMCE
require 'tiny_mce/base'
require 'tiny_mce/exceptions'
require 'tiny_mce/configuration'
require 'tiny_mce/spell_checker'
require 'tiny_mce/helpers'

module TinyMCE
  def self.initialize
    return if @intialized
    raise "ActionController is not available yet." unless defined?(ActionController)
    ActionController::Base.send(:include, TinyMCE::Base)
    ActionController::Base.send(:helper, TinyMCE::Helpers)
    # TinyMCE.install_or_update_tinymce
    @intialized = true
  end

  def self.install_or_update_tinymce
    require 'fileutils'
    orig = File.join(File.dirname(__FILE__), 'tiny_mce', 'assets', 'tiny_mce')
    dest = File.join(Rails.root.to_s, 'assets', 'javascripts', 'tiny_mce')
    tiny_mce_js = File.join(dest, 'tiny_mce.js')

    unless File.exists?(tiny_mce_js) && FileUtils.identical?(File.join(orig, 'tiny_mce.js'), tiny_mce_js)
      if File.exists?(tiny_mce_js)
        # upgrade
        begin
          puts "Removing directory #{dest}..."
          FileUtils.rm_rf dest
          puts "Creating directory #{dest}..."
          FileUtils.mkdir_p dest
          puts "Copying TinyMCE to #{dest}..."
          FileUtils.cp_r "#{orig}/.", dest
          puts "Successfully updated TinyMCE."
        rescue
          puts 'ERROR: Problem updating TinyMCE. Please manually copy '
          puts orig
          puts 'to'
          puts dest
        end
      else
        # install
        begin
          puts "Creating directory #{dest}..."
          FileUtils.mkdir_p dest
          puts "Copying TinyMCE to #{dest}..."
          FileUtils.cp_r "#{orig}/.", dest
          puts "Successfully installed TinyMCE."
        rescue
          puts "ERROR: Problem installing TinyMCE. Please manually copy "
          puts orig
          puts "to"
          puts dest
        end
      end
    end

    tiny_mce_yaml_filepath = File.join(Rails.root.to_s, 'config', 'tiny_mce.yml')
    unless File.exists?(tiny_mce_yaml_filepath)
      File.open(tiny_mce_yaml_filepath, 'w') do |f|
        f.puts '# Here you can specify default options for TinyMCE across all controllers'
        f.puts '#'
        f.puts '# theme: advanced'
        f.puts '# plugins:'
        f.puts '#  - table'
        f.puts '#  - fullscreen'
      end
      puts "Written configuration example to #{tiny_mce_yaml_filepath}"
    end
  end
  
  #this method generate new language to tinyMCE
  def self.generate_new_lang(env_lang)
    
    puts "---------------------------------------------------------------------------------------"
    puts "\t\t TinyMCE Language Basic Generator"
    puts "---------------------------------------------------------------------------------------"
    unless env_lang.empty?
    
      lib_tinymce = File.join(File.dirname(__FILE__), 'tiny_mce')
      file = File.join(lib_tinymce, "valid_tinymce_langs.yml")
      yml_langs = YAML::load(File.open(file))

      unless yml_langs.include?(env_lang)
        yml_langs << env_lang
        yml_langs.sort!
    
        #writing new language to valid_tinymce_langs.yml
        File.open(file, 'w') do |f|
          f << "#\n# For more information about available languages, see\n"
          f <<  "# http://tinymce.moxiecode.com/download_i18n.php\n"
          f << "# Should only include a list of completed translations (not incomplete ones which most are :-( )\n#\n\n"
          f << YAML.dump(yml_langs).to_s
        end
         #start to copy en files to new lang
          puts "Generated \"en\" lang copies, translate this files:"
          puts "---------------------------------------------------------------------------------------"
          puts " REMEMBER TO CHANGE ALL THIS FILES."
          puts "IF YOU WANT TO TRANSLATE AN ESPECIFIC PLUGIN GO TO plugin/langs AND ADD YOUR LANG\n\n"
        
      else
        puts "\n\n\t\tLanguage exists on configuration file.\n\n" 
      end
    
      assets_path = File.join(lib_tinymce, 'assets', 'tiny_mce') 
      unless File.exists?(File.join(assets_path, 'langs',"#{env_lang}.js"))
        puts "\t- tiny_mce/lib/tiny_mce/assets/tiny_mce/langs/#{env_lang}.js"
        FileUtils.cp( File.join(assets_path, "langs", "en.js"), File.join(assets_path, "langs","#{env_lang}.js")) 
      end
      unless File.exists?(File.join(assets_path,"themes","advanced","langs","#{env_lang}.js"))
        puts "\t- tiny_mce/lib/tiny_mce/assets/tiny_mce/themes/advanced/langs/#{env_lang}.js"
        FileUtils.cp(File.join(assets_path,"themes","advanced","langs","en.js"), File.join(assets_path,"themes","advanced","langs","#{env_lang}.js")) 
      end
      unless File.exists?(File.join(assets_path,"themes","advanced","langs","#{env_lang}_dlg.js"))
        puts "\t- tiny_mce/lib/tiny_mce/assets/tiny_mce/themes/advanced/langs/#{env_lang}_dlg.js"
        FileUtils.cp(File.join(assets_path,"themes","advanced","langs","en_dlg.js"), File.join(assets_path,"themes","advanced","langs","#{env_lang}_dlg.js"))
      end
      unless File.exists?(File.join(assets_path,"themes","simple","langs","#{env_lang}.js"))
        puts "\t- tiny_mce/lib/tiny_mce/assets/tiny_mce/themes/simple/langs/#{env_lang}_dlg.js"
        FileUtils.cp(File.join(assets_path,"themes","simple","langs","en.js"), File.join(assets_path,"themes","simple","langs","#{env_lang}.js")) 
      end
    
      puts "---------------------------------------------------------------------------------------"
    
    else
      puts "You must set the LANG environment. example: rake tiny_mce:new:lang LANG=pt-BR"
    end
  end

  module Base
    include TinyMCE::SpellChecker
  end

  # Plugin Support
  class Plugin
    cattr_accessor :assets_path
    def self.install
      return unless File.directory?(self.assets_path)
      require 'fileutils'
      puts "Installing #{self.name} plugin assets from #{self.assets_path}"
      FileUtils.cp_r "#{self.assets_path}/.", File.join(Rails.root.to_s, 'public', 'javascripts', 'tiny_mce')
    end
  end
end

# Finally, lets include the TinyMCE base and helpers where
# they need to go (support for Rails 2 and Rails 3)
if defined?(Rails::Railtie)
  require 'tiny_mce/railtie'
else
  TinyMCE.initialize
end
