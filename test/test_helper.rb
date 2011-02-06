# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../testapp/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }


require "authlogic/test_case"
require "authenticated_test_helper"
ActiveSupport::TestCase.fixture_path = (Rails.root + "../fixtures/")
ActionController::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path


class ActionController::TestCase
  setup :activate_authlogic
end

class ActiveSupport::TestCase      
  include AuthenticatedTestHelper
  
  def self.all_fixtures
    # fixtures :forums, :users, :sb_posts, :topics, :moderatorships, :monitorships, :categories
    fixtures :all
  end  
  
  def teardown
    UserSession.find && UserSession.find.destroy
  end

  # Add more helper methods to be used by all tests here...
  def assert_difference(object, method = nil, difference = 1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method)
  end

  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end 
  
  def authorize_as(user, mime_type = 'application/xml')
    @request.env["HTTP_AUTHORIZATION"] = user ? "Basic #{Base64.encode64("#{users(user).login}:testy")}" : nil
  end

  def content_type(type)
    @request.env['Content-Type'] = type
  end

  def accept(accept)
    @request.env["HTTP_ACCEPT"] = accept
  end

  def assert_models_equal(expected_models, actual_models, message = nil)
    #gross
    to_test_param = lambda { |r| "<#{r.class}:#{r.to_param}>" }
    full_message = build_message(message, "<?> expected but was\n<?>.\n", 
      expected_models.collect(&to_test_param), actual_models.collect(&to_test_param))
    assert_block(full_message) { (expected_models == actual_models || expected_models == actual_models.results) }
  end
  
  def assert_js_redirected_to(options={}, message=nil)
    clean_backtrace do
      assert_response(:success, message)
      assert_match /text\/javascript/, @response.headers['Content-Type'], 'Response should be Javascript content-type';
      js_regexp = %r{(\w+://)?.*?(/|$|\\\?)(.*)}
      url_regexp = %r{^window\.location\.href [=] ['"]#{js_regexp}['"][;]$}
      redirected_to = @response.body.match(url_regexp)
      assert_not_nil(redirected_to, message)
      redirected_to = redirected_to[3]
      msg = build_message(message, "expected a JS redirect to , found one to ", options, redirected_to)

      if options.is_a?(String)
        assert_equal(options.gsub(/^\//, ''), redirected_to, message)
      else
        msg = build_message(message, "response is not a redirection to all of the options supplied (redirection is )", redirected_to)
        assert_equal(@controller.url_for(options).match(js_regexp)[3], redirected_to, msg)
      end
    end
  end
   
end

# Redefining this so we don't have to go out to the interwebs everytime we create a clipping
# file paramater must equal http://www.google.com/intl/en_ALL/images/logo.gif; all other strings are considered an invalid URL
# module UrlUpload
#   # include ActionDispatch::TestProcess  
#   attr_accessor :data 
#   
#   def data_from_url(uri)
#     data ||= ActionController::TestUploadedFile.new(Rails.root+"/vendor/plugins/community_engine/test/fixtures/files/library.jpg", 'image/jpg', false)    
#     if ['http://www.google.com/intl/en_ALL/images/logo.gif', 'http://us.i1.yimg.com/us.yimg.com/i/ww/beta/y3.gif'].include?(uri)
#       data
#     else
#       nil
#     end
#   end      
# end

# class Hash
#   # Usage { :a => 1, :b => 2, :c => 3}.except(:a) -> { :b => 2, :c => 3}
#   def except(*keys)
#     self.reject { |k,v|
#       keys.include? k.to_sym
#     }
#   end
# 
#   # Usage { :a => 1, :b => 2, :c => 3}.only(:a) -> {:a => 1}
#   def only(*keys)
#     self.dup.reject { |k,v|
#       !keys.include? k.to_sym
#     }
#   end
# end
