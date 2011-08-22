require 'deface'

module CommunityEngine
  module ThemeSupport

    # This class is all deprecated and will be removed, currently being used as bridge
    # between old style hooks and new Deface methods.
    class HookListener
      include Singleton

      def self.replace(hook_name, options = {}, &block)
        create_deface_override(:replace, hook_name, options, &block)
      end

      def self.insert_before(hook_name, options = {}, &block)
        create_deface_override(:insert_before, hook_name, options, &block)
      end

      def self.insert_after(hook_name, options = {}, &block)
        create_deface_override(:insert_after, hook_name, options, &block)
      end

      def self.insert_top(hook_name, options = {}, &block)
        create_deface_override(:insert_top, hook_name, options, &block)
      end

      def self.insert_bottom(hook_name, options = {}, &block)
        create_deface_override(:insert_bottom, hook_name, options, &block)
      end

      def self.remove(hook_name)
        add_hook_modifier(hook_name, :replace)
      end

      private
        def self.create_deface_override(target, hook_name, options, &block)
          virtual_path = migratable_hooks.detect{|path, hooks| hooks.include? hook_name.to_sym }.try(:first)
          return if virtual_path.nil?

          if block_given?
            action = "text"
            content = yield
            content.gsub!(/["]/, '\\\"')
          else
            if options.is_a? String
              action = "partial"
              content = options
            else
              if options.key? :partial
                action = "partial"
                content = options[:partial]
              elsif options.key? :text
                action = "text"
                content = options[:text]
              elsif options.key? :template
                action = "template"
                content = options[:template]
              end
            end
          end
          content ||= ""

          override = %Q{Deface::Override.new(:virtual_path => "#{virtual_path}",
                     :name => "converted_#{hook_name}_#{rand(1000000000)}",
                     :#{target} => "[data-hook='#{hook_name}'], ##{hook_name}[data-hook]",
                     :#{action} => "#{content}",
                     :disabled => false)}

          warn "[DEPRECATION] `#{target}` hook method is deprecated, replace hook call with: \n#{override}\n"
          eval override
        end

        def self.migratable_hooks
          {
            'layouts/application' => [:inside_head, :sidebar]
          }
        end
    end

  end
end
