# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

# require 'simplecov'
require File.expand_path('../../../simplecov/lib/simplecov', __FILE__)
SimpleCov.start do
  add_filter '/config/'
  add_filter '/vendor/'  
  
  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Helpers', 'app/helpers'
  add_group 'Libraries', 'lib'
  add_group 'Tests', 'test'
end

require File.expand_path("../testapp/config/environment",  __FILE__)
require "rails/test_help"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

require "authlogic/test_case"
require "community_engine/authenticated_test_helper"

ActiveSupport::TestCase.fixture_path = (Rails.root + "../fixtures").to_s #we want a string here, not a Pathname
ActionController::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path

# OmniAuth.config.test_mode = true
# OmniAuth.config.mock_auth[:default] = {
#   'uid' => '123545'
#   'nickname' => 'Omniauth-user'
#   'email' => 'email@example.com'
# }


class ActionController::TestCase
  setup :activate_authlogic
end

class ActiveSupport::TestCase      
  setup :activate_authlogic
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
module UrlUpload
  include ActionDispatch::TestProcess  
  attr_accessor :data 
  
  def data_from_url(uri)
    data ||= Rack::Test::UploadedFile.new("#{File.dirname(__FILE__)}/fixtures/files/library.jpg", 'image/jpg', false)
    if ['http://www.google.com/intl/en_ALL/images/logo.gif', 'http://us.i1.yimg.com/us.yimg.com/i/ww/beta/y3.gif'].include?(uri)
      data
    else
      nil
    end
  end      
end
