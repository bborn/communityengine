#!/usr/bin/env ruby

#  This software code is made available "AS IS" without warranties of any
#  kind.  You may copy, display, modify and redistribute the software
#  code either by itself or as incorporated into your code; provided that
#  you do not remove any proprietary notices.  Your use of this software
#  code is at your own risk and you waive any claim against Amazon
#  Digital Services, Inc. or its affiliates with respect to your use of
#  this software code. (c) 2006 Amazon Digital Services, Inc. or its
#  affiliates.

require 's3'
require 'time' # for httpdate

AWS_ACCESS_KEY_ID = '1MDCWZHGB8F98EBAHV82'
AWS_SECRET_ACCESS_KEY = 'In7gs33pyYzVOUEfN+PZVwlweRoykF98PhLnt+MF'
# remove these next two lines as well, when you've updated your credentials.

BUCKET_NAME = AWS_ACCESS_KEY_ID + '-test-bucket'
KEY_NAME = 'test-key'

conn = S3::AWSAuthConnection.new(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)

print "----- creating bucket -----\n"
p conn.create_bucket(BUCKET_NAME).http_response.message

print "----- listing bucket -----\n"
p conn.list_bucket(BUCKET_NAME).entries.map { |entry| entry.key }

print "----- putting object -----\n"
p conn.put(
  BUCKET_NAME,
  KEY_NAME,
  S3::S3Object.new("this is a test"),
  { 'Content-Type' => 'text/plain' }
).http_response.message

print "----- listing bucket -----\n"
p conn.list_bucket(BUCKET_NAME).entries.map { |entry| entry.key }

print "----- query string authentication example -----\n"
print "\nTry this url out in your browser (it will only be valid for 60 seconds).\n\n"
generator = S3::QueryStringAuthGenerator.new(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
generator.expires_in = 60
url = generator.get(BUCKET_NAME, KEY_NAME)
print url, "\n"
print "\npress enter> "
STDIN.getc

print "\nNow try just the url without the query string arguments.  it should fail.\n\n"
print url.gsub(/\?.*$/, ''), "\n"
print "\npress enter> "
STDIN.getc

print "----- putting new object with metadata and public read acl -----\n"
p conn.put(
  BUCKET_NAME,
  KEY_NAME + '-public',
  S3::S3Object.new("this is a publicly readable test", {'blah' => 'foo'}),
  { 'x-amz-acl' => 'public-read', 'Content-Type' => 'text/plain' }
).http_response.message

print "----- anonymous read test ----\n"
print "\nYou should be able to try this in your browser\n\n"
print generator.get(BUCKET_NAME, KEY_NAME + '-public').gsub(/\?.*$/, ''), "\n"
print "\npress enter> "
STDIN.getc

print "----- getting object's acl -----\n"
p conn.get_acl(BUCKET_NAME, KEY_NAME).object.data

print "----- deleting objects -----\n"
p conn.delete(BUCKET_NAME, KEY_NAME).http_response.message
p conn.delete(BUCKET_NAME, KEY_NAME + '-public').http_response.message

print "----- listing bucket -----\n"
p conn.list_bucket(BUCKET_NAME).entries.map { |entry| entry.key }

print "----- listing all my buckets -----\n"
p conn.list_all_my_buckets.entries.map { |bucket| bucket.name }

print "----- deleting bucket -----\n"
p conn.delete_bucket(BUCKET_NAME).http_response.message

