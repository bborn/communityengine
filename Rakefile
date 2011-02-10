require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the community_engine plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the community_engine plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'CommunityEngine'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name = "community_engine"
    gem.summary = "CommunityEngine for Rails 3"
    gem.email = 'admin@curbly.com'
    gem.authors = ["Bruno Bornsztein"]    
    gem.version = '1.9.9'
    
    gem.add_dependency 'rails', '3.1.0.beta'
    gem.add_dependency 'rack', '1.2.1'    
    gem.add_dependency 'configatron'
    gem.add_dependency 'hpricot'
    gem.add_dependency 'htmlentities'
    gem.add_dependency 'haml'
    gem.add_dependency 'calendar_date_select'
    gem.add_dependency 'ri_cal'
    gem.add_dependency 'authlogic'

    # gem.add_dependency 'rd_searchlogic', '3.0.1'
    gem.add_dependency 'meta_search'
    
    gem.add_dependency 'rakismet'
    gem.add_dependency 'aws-s3'
    gem.add_dependency "will_paginate", "~> 3.0.pre2"
    gem.add_dependency "dynamic_form"
    gem.add_dependency 'acts_as_commentable', '~> 3.0.0'    
    
        
    # other fields that would normally go in your gemspec
    # like authors, email and has_rdoc can also be included here

  end
rescue
  puts "Jeweler or one of its dependencies is not installed."
end