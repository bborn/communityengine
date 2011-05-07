if defined?(Rails::Railtie)
  module TinyMCE
    class Railtie < Rails::Railtie
      rake_tasks do
        load "tasks/tiny_mce.rake"
      end

      initializer :tiny_mce do
        TinyMCE.initialize
      end
    end
  end
end
