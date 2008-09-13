class <%= singular_camel_case_name %> < ActiveRecord::Base

  is_private_message<% unless singular_camel_case_parent == "User" %> :class_name => "<%= "#{singular_camel_case_parent}" %>"<% end %>
  
  # The :to accessor is used by the scaffolding,
  # uncomment it if using it or you can remove it if not
  #attr_accessor :to
  
end