module ActionController
  module Resources
    class Resource
    
      def member_path
        options[:member_path] || "#{path}/:id"
      end

      def nesting_path_prefix
        options[:nested_member_path] || options[:member_path] || "#{path}/:#{singular}_id"
      end
    end
  end
end
