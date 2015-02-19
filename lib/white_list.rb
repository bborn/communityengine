require 'white_list/white_list_helper'
ActionView::Base.send :include, WhiteListHelper
ActiveRecord::Base.send :include, WhiteListHelper

ActiveRecord::Base.class_eval do
  # include ActionView::Helpers::TagHelper, ActionView::Helpers::TextHelper, WhiteListHelper, ActionView::Helpers::UrlHelper

  def self.format_attribute(attr_name)
    class << self; include ActionView::Helpers::TagHelper, ActionView::Helpers::TextHelper, WhiteListHelper; end
    define_method(:body)       { read_attribute attr_name }
    define_method(:body=)      { |value| write_attribute "#{attr_name}", value }
    define_method(:body_html)  { read_attribute "#{attr_name}_html" }
    define_method(:body_html=) { |value| write_attribute "#{attr_name}_html", value }
    before_save :format_content
  end

  protected
    def format_content
      body.strip! if body.respond_to?(:strip!)
      self.body_html = body.blank? ? '' : body_html_with_formatting
      self.body = white_list(self.body)
    end

    def body_html_with_formatting
      white_list(body_html)
    end
end
