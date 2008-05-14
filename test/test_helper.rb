ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")

require 'test_help'
require 'pp'
Test::Unit::TestCase.fixture_path = (RAILS_ROOT + "/vendor/plugins/community_engine/test/fixtures/")
ActionController::IntegrationTest.fixture_path = Test::Unit::TestCase.fixture_path


class Test::Unit::TestCase
  include AuthenticatedTestHelper
  
  def self.all_fixtures
    fixtures :forums, :users, :sb_posts, :topics, :moderatorships, :monitorships, :categories
  end  
  
  def teardown
    @request.session[:user] = nil if @request
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
    to_test_param = lambda { |r| "<#{r.class}:#{r.to_param}>" }
    full_message = build_message(message, "<?> expected but was\n<?>.\n", 
      expected_models.collect(&to_test_param), actual_models.collect(&to_test_param))
    assert_block(full_message) { expected_models == actual_models }
  end
   
end

class Hash
  # Usage { :a => 1, :b => 2, :c => 3}.except(:a) -> { :b => 2, :c => 3}
  def except(*keys)
    self.reject { |k,v|
      keys.include? k.to_sym
    }
  end

  # Usage { :a => 1, :b => 2, :c => 3}.only(:a) -> {:a => 1}
  def only(*keys)
    self.dup.reject { |k,v|
      !keys.include? k.to_sym
    }
  end
end
