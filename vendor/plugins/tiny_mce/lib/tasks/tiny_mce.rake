namespace :tiny_mce do

  desc 'Install or update the TinyMCE sources'
  task :install => :environment do
    TinyMCE.install_or_update_tinymce
  end
  
  namespace :new do
    
    desc 'Generate TinyMCE language files LANG=name'
    task :lang => :environment do
      env_lang = ENV['LANG']
      TinyMCE.generate_new_lang(env_lang)
    end
  end

end
