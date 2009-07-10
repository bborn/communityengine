#!/usr/bin/env ruby

#  This software code is made available "AS IS" without warranties of any
#  kind.  You may copy, display, modify and redistribute the software
#  code either by itself or as incorporated into your code; provided that
#  you do not remove any proprietary notices.  Your use of this software
#  code is at your own risk and you waive any claim against Amazon
#  Digital Services, Inc. or its affiliates with respect to your use of
#  this software code. (c) 2006 Amazon Digital Services, Inc. or its
#  affiliates.

require 'base64'
require 'cgi'
require 'openssl'
require 'digest/sha1'
require 'net/https'
require 'rexml/document'
require 'time'

# this wasn't added until v 1.8.3
if (RUBY_VERSION < '1.8.3')
  class Net::HTTP::Delete < Net::HTTPRequest
    METHOD = 'DELETE'
    REQUEST_HAS_BODY = false
    RESPONSE_HAS_BODY = true
  end
end

# this module has two big classes: AWSAuthConnection and
# QueryStringAuthGenerator.  both use identical apis, but the first actually
# performs the operation, while the second simply outputs urls with the
# appropriate authentication query string parameters, which could be used
# in another tool (such as your web browser for GETs).
module S3
  DEFAULT_HOST = 's3.amazonaws.com'
  PORTS_BY_SECURITY = { true => 443, false => 80 }
  METADATA_PREFIX = 'x-amz-meta-'
  AMAZON_HEADER_PREFIX = 'x-amz-'

  # builds the canonical string for signing.
  def S3.canonical_string(method, path, headers={}, expires=nil)
    interesting_headers = {}
    headers.each do |key, value|
      lk = key.downcase
      if (lk == 'content-md5' or
          lk == 'content-type' or
          lk == 'date' or
          lk =~ /^#{AMAZON_HEADER_PREFIX}/o)
        interesting_headers[lk] = value.to_s.strip
      end
    end

    # these fields get empty strings if they don't exist.
    interesting_headers['content-type'] ||= ''
    interesting_headers['content-md5'] ||= ''

    # just in case someone used this.  it's not necessary in this lib.
    if interesting_headers.has_key? 'x-amz-date'
      interesting_headers['date'] = ''
    end

    # if you're using expires for query string auth, then it trumps date
    # (and x-amz-date)
    if not expires.nil?
      interesting_headers['date'] = expires
    end

    buf = "#{method}\n"
    interesting_headers.sort { |a, b| a[0] <=> b[0] }.each do |key, value|
      if key =~ /^#{AMAZON_HEADER_PREFIX}/o
        buf << "#{key}:#{value}\n"
      else
        buf << "#{value}\n"
      end
    end

    # ignore everything after the question mark...
    buf << path.gsub(/\?.*$/, '')

    # ...unless there is an acl or torrent parameter
    if path =~ /[&?]acl($|&|=)/
      buf << '?acl'
    elsif path =~ /[&?]torrent($|&|=)/
      buf << '?torrent'
    elsif path =~ /[&?]logging($|&|=)/
      buf << '?logging'
    end

    return buf
  end

  # encodes the given string with the aws_secret_access_key, by taking the
  # hmac-sha1 sum, and then base64 encoding it.  optionally, it will also
  # url encode the result of that to protect the string if it's going to
  # be used as a query string parameter.
  def S3.encode(aws_secret_access_key, str, urlencode=false)
    digest = OpenSSL::Digest::Digest.new('sha1')
    b64_hmac =
      Base64.encode64(
        OpenSSL::HMAC.digest(digest, aws_secret_access_key, str)).strip

    if urlencode
      return CGI::escape(b64_hmac)
    else
      return b64_hmac
    end
  end


  # uses Net::HTTP to interface with S3.  note that this interface should only
  # be used for smaller objects, as it does not stream the data.  if you were
  # to download a 1gb file, it would require 1gb of memory.  also, this class
  # creates a new http connection each time.  it would be greatly improved with
  # some connection pooling.
  class AWSAuthConnection
    def initialize(aws_access_key_id, aws_secret_access_key, is_secure=true,
                   server=DEFAULT_HOST, port=PORTS_BY_SECURITY[is_secure])
      @aws_access_key_id = aws_access_key_id
      @aws_secret_access_key = aws_secret_access_key
      @http = Net::HTTP.new(server, port)
      @http.use_ssl = is_secure
    end

    def create_bucket(bucket, headers={})
      return Response.new(make_request('PUT', bucket, headers))
    end

    # takes options :prefix, :marker, :max_keys, and :delimiter
    def list_bucket(bucket, options={}, headers={})
      path = bucket
      if options.size > 0
          path += '?' + options.map { |k, v| "#{k}=#{CGI::escape v.to_s}" }.join('&')
      end

      return ListBucketResponse.new(make_request('GET', path, headers))
    end

    def delete_bucket(bucket, headers={})
      return Response.new(make_request('DELETE', bucket, headers))
    end

    def put(bucket, key, object, headers={})
      object = S3Object.new(object) if not object.instance_of? S3Object

      return Response.new(
        make_request('PUT', "#{bucket}/#{CGI::escape key}", headers, object.data, object.metadata)
      )
    end

    def get(bucket, key, headers={})
      return GetResponse.new(make_request('GET', "#{bucket}/#{CGI::escape key}", headers))
    end

    def delete(bucket, key, headers={})
      return Response.new(make_request('DELETE', "#{bucket}/#{CGI::escape key}", headers))
    end

    def get_bucket_logging(bucket, headers={})
      return GetResponse.new(make_request('GET', "#{bucket}?logging", headers))
    end

    def put_bucket_logging(bucket, logging_xml_doc, headers={})
      return Response.new(make_request('PUT', "#{bucket}?logging", headers, logging_xml_doc))
    end

    def get_bucket_acl(bucket, headers={})
      return get_acl(bucket, '', headers)
    end

    # returns an xml document representing the access control list.
    # this could be parsed into an object.
    def get_acl(bucket, key, headers={})
      return GetResponse.new(make_request('GET', "#{bucket}/#{CGI::escape key}?acl", headers))
    end

    def put_bucket_acl(bucket, acl_xml_doc, headers={})
      return put_acl(bucket, '', acl_xml_doc, headers)
    end

    # sets the access control policy for the given resource.  acl_xml_doc must
    # be a string in the acl xml format.
    def put_acl(bucket, key, acl_xml_doc, headers={})
      return Response.new(
        make_request('PUT', "#{bucket}/#{CGI::escape key}?acl", headers, acl_xml_doc, {})
      )
    end

    def list_all_my_buckets(headers={})
      return ListAllMyBucketsResponse.new(make_request('GET', '', headers))
    end

    private
    def make_request(method, path, headers={}, data='', metadata={})
      @http.start do
        req = method_to_request_class(method).new("/#{path}")

        set_headers(req, headers)
        set_headers(req, metadata, METADATA_PREFIX)

        set_aws_auth_header(req, @aws_access_key_id, @aws_secret_access_key)
        if req.request_body_permitted?
          return @http.request(req, data)
        else
          return @http.request(req)
        end
      end
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

    # set the Authorization header using AWS signed header authentication
    def set_aws_auth_header(request, aws_access_key_id, aws_secret_access_key)
      # we want to fix the date here if it's not already been done.
      request['Date'] ||= Time.now.httpdate

      # ruby will automatically add a random content-type on some verbs, so
      # here we add a dummy one to 'supress' it.  change this logic if having
      # an empty content-type header becomes semantically meaningful for any
      # other verb.
      request['Content-Type'] ||= ''

      canonical_string =
        S3.canonical_string(request.method, request.path, request.to_hash)
      encoded_canonical = S3.encode(aws_secret_access_key, canonical_string)

      request['Authorization'] = "AWS #{aws_access_key_id}:#{encoded_canonical}"
    end

    def set_headers(request, headers, prefix='')
      headers.each do |key, value|
        request[prefix + key] = value
      end
    end
  end


  # This interface mirrors the AWSAuthConnection class above, but instead
  # of performing the operations, this class simply returns a url that can
  # be used to perform the operation with the query string authentication
  # parameters set.
  class QueryStringAuthGenerator
    attr_accessor :expires
    attr_accessor :expires_in
    attr_reader :server
    attr_reader :port

    # by default, expire in 1 minute
    DEFAULT_EXPIRES_IN = 60

    def initialize(aws_access_key_id, aws_secret_access_key, is_secure=true, server=DEFAULT_HOST, port=PORTS_BY_SECURITY[is_secure])
      @aws_access_key_id = aws_access_key_id
      @aws_secret_access_key = aws_secret_access_key
      @protocol = is_secure ? 'https' : 'http'
      @server = server
      @port = port
      # by default expire
      @expires_in = DEFAULT_EXPIRES_IN
    end

    # set the expires value to be a fixed time.  the argument can
    # be either a Time object or else seconds since epoch.
    def expires=(value)
      @expires = value
      @expires_in = nil
    end

    # set the expires value to expire at some point in the future
    # relative to when the url is generated.  value is in seconds.
    def expires_in=(value)
      @expires_in = value
      @expires = nil
    end

    def create_bucket(bucket, headers={})
      return generate_url('PUT', bucket, headers)
    end

    # takes options :prefix, :marker, :max_keys, and :delimiter
    def list_bucket(bucket, options={}, headers={})
      path = bucket
      if options.size > 0
        path += '?' + options.map { |k, v| "#{k}=#{CGI::escape v}" }.join('&')
      end

      return generate_url('GET', path, headers)
    end

    def delete_bucket(bucket, headers={})
      return generate_url('DELETE', bucket, headers)
    end

    # don't really care what object data is.  it's just for conformance with the
    # other interface.  If this doesn't work, check tcpdump to see if the client is
    # putting a Content-Type header on the wire.
    def put(bucket, key, object=nil, headers={})
      object = S3Object.new(object) if not object.instance_of? S3Object
      return generate_url('PUT', "#{bucket}/#{CGI::escape key}", merge_meta(headers, object))
    end

    def get(bucket, key, headers={})
      return generate_url('GET',  "#{bucket}/#{CGI::escape key}", headers)
    end

    def delete(bucket, key, headers={})
      return generate_url('DELETE',  "#{bucket}/#{CGI::escape key}", headers)
    end

    def get_bucket_logging(bucket, headers={})
      return generate_url('GET', "#{bucket}?logging", headers)
    end

    def put_bucket_logging(bucket, logging_xml_doc, headers={})
      return generate_url('PUT', "#{bucket}?logging", headers)
    end

    def get_acl(bucket, key='', headers={})
      return generate_url('GET', "#{bucket}/#{CGI::escape key}?acl", headers)
    end

    def get_bucket_acl(bucket, headers={})
      return get_acl(bucket, '', headers)
    end

    # don't really care what acl_xml_doc is.
    # again, check the wire for Content-Type if this fails.
    def put_acl(bucket, key, acl_xml_doc, headers={})
      return generate_url('PUT', "#{bucket}/#{CGI::escape key}?acl", headers)
    end

    def put_bucket_acl(bucket, acl_xml_doc, headers={})
      return put_acl(bucket, '', acl_xml_doc, headers)
    end

    def list_all_my_buckets(headers={})
      return generate_url('GET', '', headers)
    end


    private
    # generate a url with the appropriate query string authentication
    # parameters set.
    def generate_url(method, path, headers)
      expires = 0
      if not @expires_in.nil?
        expires = Time.now.to_i + @expires_in
      elsif not @expires.nil?
        expires = @expires
      else
        raise "invalid expires state"
      end

      canonical_string =
        S3::canonical_string(method, "/" + path, headers, expires)
      encoded_canonical =
        S3::encode(@aws_secret_access_key, canonical_string, true)

      arg_sep = path.index('?') ? '&' : '?'

      return "#{@protocol}://#{@server}:#{@port}/#{path}#{arg_sep}Signature=#{encoded_canonical}&Expires=#{expires}&AWSAccessKeyId=#{@aws_access_key_id}"
    end

    def merge_meta(headers, object)
      final_headers = headers.clone
      if not object.nil? and not object.metadata.nil?
        object.metadata.each do |k, v|
          final_headers[METADATA_PREFIX + k] = v
        end
      end
      return final_headers
    end
  end

  class S3Object
    attr_accessor :data
    attr_accessor :metadata
    def initialize(data, metadata={})
      @data, @metadata = data, metadata
    end
  end

  class Owner
    attr_accessor :id
    attr_accessor :display_name
  end

  class ListEntry
    attr_accessor :key
    attr_accessor :last_modified
    attr_accessor :etag
    attr_accessor :size
    attr_accessor :storage_class
    attr_accessor :owner
  end

  class ListProperties
    attr_accessor :name
    attr_accessor :prefix
    attr_accessor :marker
    attr_accessor :max_keys
    attr_accessor :delimiter
    attr_accessor :is_truncated
    attr_accessor :next_marker
  end

  class CommonPrefixEntry
    attr_accessor :prefix
  end

  # Parses the list bucket output into a list of ListEntry objects, and
  # a list of CommonPrefixEntry objects if applicable.
  class ListBucketParser
    attr_reader :properties
    attr_reader :entries
    attr_reader :common_prefixes

    def initialize
      reset
    end

    def tag_start(name, attributes)
      if name == 'ListBucketResult'
        @properties = ListProperties.new
      elsif name == 'Contents'
        @curr_entry = ListEntry.new
      elsif name == 'Owner'
        @curr_entry.owner = Owner.new
      elsif name == 'CommonPrefixes'
        @common_prefix_entry = CommonPrefixEntry.new
      end      
    end

    # we have one, add him to the entries list
    def tag_end(name)
      # this prefix is the one we echo back from the request
      if name == 'Name'
        @properties.name = @curr_text
      elsif name == 'Prefix' && @is_echoed_prefix
        @properties.prefix = @curr_text       
        @is_echoed_prefix = nil
      elsif name == 'Marker'
        @properties.marker = @curr_text
      elsif name == 'MaxKeys'
        @properties.max_keys = @curr_text.to_i
      elsif name == 'Delimiter'
        @properties.delimiter = @curr_text
      elsif name == 'IsTruncated'
        @properties.is_truncated = @curr_text == 'true'
      elsif name == 'NextMarker'        
        @properties.next_marker = @curr_text
      elsif name == 'Contents'
        @entries << @curr_entry
      elsif name == 'Key'
        @curr_entry.key = @curr_text
      elsif name == 'LastModified'
        @curr_entry.last_modified = @curr_text
      elsif name == 'ETag'
        @curr_entry.etag = @curr_text
      elsif name == 'Size'
        @curr_entry.size = @curr_text.to_i
      elsif name == 'StorageClass'
        @curr_entry.storage_class = @curr_text
      elsif name == 'ID'
        @curr_entry.owner.id = @curr_text
      elsif name == 'DisplayName'
        @curr_entry.owner.display_name = @curr_text
      elsif name == 'CommonPrefixes'
        @common_prefixes << @common_prefix_entry         
      elsif name == 'Prefix'
        # this is the common prefix for keys that match up to the delimiter
        @common_prefix_entry.prefix = @curr_text
      end
      @curr_text = ''
    end

    def text(text)
        @curr_text += text
    end

    def xmldecl(version, encoding, standalone)
      # ignore
    end

    # get ready for another parse
    def reset
      @is_echoed_prefix = true;
      @entries = []
      @curr_entry = nil
      @common_prefixes = []
      @common_prefix_entry = nil
      @curr_text = ''
    end
  end

  class Bucket
    attr_accessor :name
    attr_accessor :creation_date
  end

  class ListAllMyBucketsParser
    attr_reader :entries

    def initialize
      reset
    end

    def tag_start(name, attributes)
      if name == 'Bucket'
        @curr_bucket = Bucket.new
      end
    end

    # we have one, add him to the entries list
    def tag_end(name)
      if name == 'Bucket'
        @entries << @curr_bucket
      elsif name == 'Name'
        @curr_bucket.name = @curr_text
      elsif name == 'CreationDate'
        @curr_bucket.creation_date = @curr_text
      end
      @curr_text = ''
    end

    def text(text)
        @curr_text += text
    end

    def xmldecl(version, encoding, standalone)
      # ignore
    end

    # get ready for another parse
    def reset
      @entries = []
      @owner = nil
      @curr_bucket = nil
      @curr_text = ''
    end
  end

  class Response
    attr_reader :http_response
    def initialize(response)
      @http_response = response
    end
  end

  class GetResponse < Response
    attr_reader :object
    def initialize(response)
      super(response)
      metadata = get_aws_metadata(response)
      data = response.body
      @object = S3Object.new(data, metadata)
    end

    # parses the request headers and pulls out the s3 metadata into a hash
    def get_aws_metadata(response)
      metadata = {}
      response.each do |key, value|
        if key =~ /^#{METADATA_PREFIX}(.*)$/oi
          metadata[$1] = value
        end
      end
      return metadata
    end
  end

  class ListBucketResponse < Response
    attr_reader :properties
    attr_reader :entries
    attr_reader :common_prefix_entries

    def initialize(response)
      super(response)
      if response.is_a? Net::HTTPSuccess
        parser = ListBucketParser.new
        REXML::Document.parse_stream(response.body, parser)
        @properties = parser.properties
        @entries = parser.entries
        @common_prefix_entries = parser.common_prefixes
      else
        @entries = []
      end
    end
  end

  class ListAllMyBucketsResponse < Response
    attr_reader :entries
    def initialize(response)
      super(response)
      if response.is_a? Net::HTTPSuccess
        parser = ListAllMyBucketsParser.new
        REXML::Document.parse_stream(response.body, parser)
        @entries = parser.entries
      else
        @entries = []
      end
    end
  end
end
