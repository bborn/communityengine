
require "#{File.dirname(__FILE__)}/../../../../config/boot.rb"
require "#{File.dirname(__FILE__)}/../../../../config/environment.rb"

require 'action_controller/test_process'
require 'test/unit'

ActionController::Base.perform_caching = true
ActionController::Routing::Routes.reload rescue nil

require "#{File.dirname(__FILE__)}/../lib/action_cache"

class ActionCacheController < ActionController::Base
  
  caches_action :a, :b, :c, :action_to_expire, :action_sets_cookie
  attr_accessor :var
  
  def a
    response.time_to_live = 1
    render :text => "Action A: Some text that will be cached: #{@var}"
  end

  def b
    response.time_to_live = 1
    render :text => "Action B: Some text that will be cached: #{@var}"
  end

  def c
    response.time_to_live = 1
    logger.info "Action C"
    render :text => "Action C: Some text that will be cached: #{@var}"
  end

  def action_sets_cookie
    cookies["one_time_only"] = "Hello!"
    render :text => "Action Sets A Cookie Value"
  end

  def action_to_expire
    logger.info "Action To Expire"
    render :text => "Action To Expire: Some text that will be cached: #{@var}"
  end

  def clear_cache_item
    expire_action :action => 'action_to_expire'
    render :text => 'Cache Item Expired'
  end
  
  def clear_all_cache
    expire_all_actions
    render :text => 'All Cache Items Expired'
  end
    
end

class ActionCacheTest < Test::Unit::TestCase
  def setup
    @controller = ActionCacheController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_action_cookie_not_cached
    get :action_sets_cookie
    assert_response :success, @response.inspect
    assert_not_nil cookies["one_time_only"]

    # Cache should drop the cookie and not return to the second request    
    get :action_sets_cookie
    assert_response :success, @response.body
    assert_nil cookies["one_time_only"]
  end

  def test_action_is_cached_with_not_modified
    get :a
    assert_response :success, @response.inspect

    @request = ActionController::TestRequest.new
    @request.env["HTTP_IF_MODIFIED_SINCE"] = @response.headers['Last-Modified']
    get :a
    assert_response 304, @response.body
  end
  
  def test_action_is_cached_without_x_sendfile
    @controller.var = "nothing"
    assert_not_equal "true", @request.env["ENABLE_X_SENDFILE"]
    get :a
    assert_response :success, @response.inspect
    assert_nil @response.headers['X-Sendfile']
    assert_match %r{nothing}, @response.body, "Body is not as expected: #{@response.body}"
    
    # Make a change that the cache won't return
    @controller.var = "something"
    get :a
    assert_response :success, @response.body
    assert_nil @response.headers['X-Sendfile']
    assert_match %r{nothing}, @response.body, "Body should not be changed: #{@response.body}"
  end
  
  def test_action_is_cached_with_x_sendfile
    @request.env['ENABLE_X_SENDFILE'] = "true"
    get :b
    assert_response :success, @response.inspect
    assert_nil @response.headers['X-Sendfile'], "No x-sendfile header expected: #{@response.headers.inspect}"

    get :b
    assert_response :success, @response.body
    assert_not_nil @response.headers['X-Sendfile'], "X-sendfile header expected: #{@response.headers.inspect}"
  end

  def test_action_is_cached_with_accel_redirect
    @request.env['HTTP_ENABLE_X_ACCEL_REDIRECT'] = "true"
    get :c
    assert_response :success, @response.inspect
    assert_nil @response.headers['X-Accel-Redirect'], "No x-accel-redirect header expected: #{@response.headers.inspect}"

    get :c
    assert_response :success, @response.body
    assert_not_nil @response.headers['X-Accel-Redirect'], "X-Accel-Redirect header expected: #{@response.headers.inspect}"
  end

  def test_expire_action
    @controller.var = "nothing"
    get :action_to_expire
    assert_response :success, @response.inspect
    assert_match %r{nothing}, @response.body, "Body is not as expected: #{@response.body}"

    @controller.var = "something"
    get :action_to_expire
    assert_response :success, @response.body
    assert_match %r{nothing}, @response.body, "Body should not be changed: #{@response.body}"

    get :clear_cache_item
    assert_response :success, @response.body

    get :action_to_expire
    assert_response :success, @response.body
    assert_match %r{something}, @response.body, "Body should be changed: #{@response.body}"
  end

  def test_expire_all_action
    @controller.var = "nothing"
    get :action_to_expire
    assert_response :success, @response.inspect
    assert_match %r{nothing}, @response.body, "Body is not as expected: #{@response.body}"

    @controller.var = "something"
    get :action_to_expire
    assert_response :success, @response.body
    assert_match %r{nothing}, @response.body, "Body should not be changed: #{@response.body}"

    get :clear_all_cache
    assert_response :success, @response.body

    get :action_to_expire
    assert_response :success, @response.body
    assert_match %r{something}, @response.body, "Body should be changed: #{@response.body}"
  end

end
