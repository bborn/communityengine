module Technoweenie
  module AttachmentFu

    module InstanceMethods

      def self.included( base )
        base.define_callbacks *[:after_resize, :after_attachment_saved, :before_thumbnail_saved]
      end  

      def callback_with_args(method, arg = self)
         notify(method)

          result = run_callbacks(method, { :object => arg }) { |result, object| result == false }

          if result != false && respond_to_without_attributes?(method)
            result = send(method)
          end

          return result
      end      

      def run_callbacks(kind, options = {}, &block)
        options.reverse_merge!( :object => self )
        # ::ActiveSupport::Callbacks::Callback.run(self.class.send("#{kind}_callback_chain"), options[:object], options, &block)
        self.class.send("#{kind}_callback_chain").run(options[:object], options, &block)
      end      
    end
  end
end