#!/usr/bin/env ruby

# This software code is made available "AS IS" without warranties of any        
# kind.  You may copy, display, modify and redistribute the software            
# code either by itself or as incorporated into your code; provided that        
# you do not remove any proprietary notices.  Your use of this software         
# code is at your own risk and you waive any claim against Amazon               
# Digital Services, Inc. or its affiliates with respect to your use of          
# this software code. (c) 2006 Amazon Digital Services, Inc. or its             
# affiliates.          

require 'test/unit'
require 'time' # for httpdate
require 's3'

AWS_ACCESS_KEY_ID = '1MDCWZHGB8F98EBAHV82'
AWS_SECRET_ACCESS_KEY = 'In7gs33pyYzVOUEfN+PZVwlweRoykF98PhLnt+MF'

BUCKET_NAME = "%s-test" % AWS_ACCESS_KEY_ID

class TC_AWSAuthConnectionTest < Test::Unit::TestCase
  def setup
    @conn = S3::AWSAuthConnection.new(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
  end

  def test_operations
    response = @conn.create_bucket(BUCKET_NAME)
    assert_instance_of(Net::HTTPOK, response.http_response, 'create bucket')

    response = @conn.list_bucket(BUCKET_NAME)
    assert_instance_of(Net::HTTPOK, response.http_response, 'list bucket')
    assert_equal(0, response.entries.length, 'bucket is empty')

    # start delimiter tests

    text = 'this is a test'
    key = 'example.txt'
    inner_key = 'test/inner.txt'
    last_key = 'z-last-key.txt'

    response = @conn.put(BUCKET_NAME, key, text)
    assert_instance_of(Net::HTTPOK, response.http_response, 'put with a string argument')

    response = @conn.put(BUCKET_NAME, inner_key, text)
    assert_instance_of(Net::HTTPOK, response.http_response, 'put with a string argument')

    response = @conn.put(BUCKET_NAME, last_key, text)
    assert_instance_of(Net::HTTPOK, response.http_response, 'put with a string argument')
    
    # plain list
    response = do_delimited_list(BUCKET_NAME, false, {}, 3, 0, 'plain list')
    
    # root "directory"
    response = do_delimited_list(BUCKET_NAME, false, {"delimiter" => "/"}, 2, 1, 'root list')
    
    # root "directory" with a max-keys of 1
    response = do_delimited_list(BUCKET_NAME, true, {"max-keys" => 1, "delimiter" => "/"}, 1, 0, 'root list with max keys of 1', 'example.txt')
    
    # root "directory" with a max-keys of 2
    response = do_delimited_list(BUCKET_NAME, true, {"max-keys" => 2, "delimiter" => "/"}, 1, 1, 'root list with max keys of 2, page 1', 'test/')
    
    marker = response.properties.next_marker
    
    response = do_delimited_list(BUCKET_NAME, false, {"marker" => marker, "max-keys" => 2, "delimiter" => "/"}, 1, 0, 'root list with max keys of 2, page 2')
    
    # test "directory"
    response = do_delimited_list(BUCKET_NAME, false, {"prefix" => "test/", "delimiter" => "/"}, 1, 0, 'test/ list')

    # remove inner key
    response = @conn.delete(BUCKET_NAME, inner_key)
    assert_instance_of(Net::HTTPNoContent, response.http_response, 'delete inner key')

    # remove last key
    response = @conn.delete(BUCKET_NAME, last_key)
    assert_instance_of(Net::HTTPNoContent, response.http_response, 'delete last key')

    # end delimiter tests

    response =
      @conn.put(
        BUCKET_NAME,
        key,
        S3::S3Object.new(text, {'title' => 'title'}),
        {'Content-Type' => 'text/plain'})

    assert_instance_of(Net::HTTPOK, response.http_response, 'put with complex argument and headers')

    response = @conn.get(BUCKET_NAME, key)
    assert_instance_of(Net::HTTPOK, response.http_response, 'get object')
    assert_equal(text, response.object.data, 'got right data')
    assert_equal( { 'title' => 'title' }, response.object.metadata, 'metadata is correct')
    assert_equal( text.length, response.http_response['Content-Length'].to_i, 'got content-length header')


    title_with_spaces = " \t  title with leading and trailing spaces    "
    response =
      @conn.put(
        BUCKET_NAME,
        key,
        S3::S3Object.new(text, {'title' => title_with_spaces}),
        {'Content-Type' => 'text/plain'})

    assert_instance_of(
      Net::HTTPOK, response.http_response, 'put with metadata with leading and trailing spaces')

    response = @conn.get(BUCKET_NAME, key)
    assert_instance_of(Net::HTTPOK, response.http_response, 'get object')
    assert_equal(
                 { 'title' => title_with_spaces.strip },      
                 response.object.metadata,                 
                 'metadata is correct')

    weird_key = '&=//%# ++++'

    response = @conn.put(BUCKET_NAME, weird_key, text)
    assert_instance_of(Net::HTTPOK, response.http_response, 'put weird key')

    response = @conn.get(BUCKET_NAME, weird_key)
    assert_instance_of(Net::HTTPOK, response.http_response, 'get weird key')

    response = @conn.get_acl(BUCKET_NAME, key)
    assert_instance_of(Net::HTTPOK, response.http_response, 'get acl')

    acl = response.object.data

    response = @conn.put_acl(BUCKET_NAME, key, acl)
    assert_instance_of(Net::HTTPOK, response.http_response, 'put acl')

    response = @conn.get_bucket_acl(BUCKET_NAME)
    assert_instance_of(Net::HTTPOK, response.http_response, 'get bucket acl')

    bucket_acl = response.object.data

    response = @conn.put_bucket_acl(BUCKET_NAME, bucket_acl)
    assert_instance_of(Net::HTTPOK, response.http_response, 'put bucket acl')

    response = @conn.get_bucket_logging(BUCKET_NAME)
    assert_instance_of(Net::HTTPOK, response.http_response, 'get bucket logging')

    bucket_logging = response.object.data

    response = @conn.put_bucket_logging(BUCKET_NAME, bucket_logging)
    assert_instance_of(Net::HTTPOK, response.http_response, 'put bucket logging')

    response = @conn.list_bucket(BUCKET_NAME)
    assert_instance_of(Net::HTTPOK, response.http_response, 'list bucket')
    entries = response.entries
    assert_equal(2, entries.length, 'got back right number of keys')
    # depends on weird_key < key
    assert_equal(weird_key, entries[0].key, 'first key is right')
    assert_equal(key, entries[1].key, 'second key is right')

    response = @conn.list_bucket(BUCKET_NAME, {'max-keys' => 1})
    assert_instance_of(Net::HTTPOK, response.http_response, 'list bucket with args')
    assert_equal(1, response.entries.length, 'got back right number of keys')

    entries.each do |entry|
      response = @conn.delete(BUCKET_NAME, entry.key)
      assert_instance_of(Net::HTTPNoContent, response.http_response, 'delete %s' % entry.key)
    end

    response = @conn.list_all_my_buckets()
    assert_instance_of(Net::HTTPOK, response.http_response, 'list all my buckets')
    buckets = response.entries

    response = @conn.delete_bucket(BUCKET_NAME)
    assert_instance_of(Net::HTTPNoContent, response.http_response, 'delete bucket')

    response = @conn.list_all_my_buckets()
    assert_instance_of(Net::HTTPOK, response.http_response, 'list all my buckets again')

    assert_equal(buckets.length - 1, response.entries.length, 'bucket count is correct')
  end

  # response: the list bucket response
  # bucket: the bucket name
  # is_truncated: whether you expect this list to be truncated
  # parameters: the parameters you specified in the list request
  # next_marker: the next_marker you expect when your list is truncated
  def verify_list_bucket_response(response, bucket, is_truncated, parameters, next_marker=nil)
    # default parameter values, these will always be echoed back despite being unspecified
    prefix = parameters["prefix"].nil? ? "" : parameters["prefix"]
    marker = parameters["marker"].nil? ? "" : parameters["marker"]    

    assert_equal(bucket, response.properties.name, "bucket name should match")
    assert_equal(prefix, response.properties.prefix, "prefix should match")
    assert_equal(marker, response.properties.marker, "marker should match")
    if !parameters["max-keys"].nil?
      assert_equal(parameters["max-keys"], response.properties.max_keys, "max-keys should match")
    end
    assert_equal(parameters["delimiter"], response.properties.delimiter, "delimiter should match")
    assert_equal(is_truncated, response.properties.is_truncated, "is_truncated should match")
    assert_equal(next_marker, response.properties.next_marker, "next_marker should match")
  end

  def do_delimited_list(bucket_name, is_truncated, parameters, regular_expected, common_expected, test_name, next_marker=nil)

    response = @conn.list_bucket(bucket_name, parameters)
    assert_instance_of(Net::HTTPOK, response.http_response, test_name)
    assert_equal(regular_expected, response.entries.length, 'right number of regular entries')
    assert_equal(common_expected, response.common_prefix_entries.length, 'right number of common prefixes')
    verify_list_bucket_response(response, bucket_name, is_truncated, parameters, next_marker)

    return response
    
  end

end

class TC_QueryStringAuthGeneratorTest < Test::Unit::TestCase
  def setup
    @generator = S3::QueryStringAuthGenerator.new(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, false)
    @http = Net::HTTP.new(@generator.server, @generator.port)
    @put_headers = { 'Content-Type' => 'text/plain' }
  end

  def method_to_request_class(method)
    case method
    when 'GET'
      return Net::HTTP::Get
    when 'PUT'
      return Net::HTTP::Put
    when 'DELETE'
      return Net::HTTP::Delete
    else
      raise "Unsupported method #{method}"
    end
  end

  def check_url(url, method, code, message, data='', headers={})
    @http.start do
      uri = URI.parse(url)
      req = method_to_request_class(method).new(uri.request_uri)
      if (method == 'PUT')
        req['Content-Length'] = data.length.to_s
        @put_headers.each do |header, value|
          req[header] = value
        end
        response = @http.request(req, data)
      else
        response = @http.request(req)
      end
      assert_instance_of(code, response, message)
      return response.body
    end
  end

  def test_operations
    key = 'test'
    check_url(@generator.create_bucket(BUCKET_NAME, @put_headers), 'PUT', Net::HTTPOK, 'create_bucket')
    check_url(@generator.put(BUCKET_NAME, key, '', @put_headers), 'PUT', Net::HTTPOK, 'put object', 'test data')
    check_url(@generator.get(BUCKET_NAME, key), 'GET', Net::HTTPOK, 'get object')
    check_url(@generator.list_bucket(BUCKET_NAME), 'GET', Net::HTTPOK, 'list bucket')
    check_url(@generator.list_all_my_buckets(), 'GET', Net::HTTPOK, 'list all my buckets')
    acl = check_url(@generator.get_acl(BUCKET_NAME, key), 'GET', Net::HTTPOK, 'get acl')
    check_url(@generator.put_acl(BUCKET_NAME, key, acl, @put_headers), 'PUT', Net::HTTPOK, 'put acl', acl)
    bucket_acl = check_url(@generator.get_bucket_acl(BUCKET_NAME), 'GET', Net::HTTPOK, 'get bucket acl')
    check_url(@generator.put_bucket_acl(BUCKET_NAME, bucket_acl, @put_headers), 'PUT', Net::HTTPOK, 'put bucket acl', bucket_acl)
    bucket_logging = check_url(@generator.get_bucket_logging(BUCKET_NAME), 'GET', Net::HTTPOK, 'get bucket logging')
    check_url(@generator.put_bucket_logging(BUCKET_NAME, bucket_logging, @put_headers), 'PUT', Net::HTTPOK, 'put bucket logging', bucket_logging)
    check_url(@generator.delete(BUCKET_NAME, key), 'DELETE', Net::HTTPNoContent, 'delete object')
    check_url(@generator.delete_bucket(BUCKET_NAME), 'DELETE', Net::HTTPNoContent, 'delete bucket')
  end
end

