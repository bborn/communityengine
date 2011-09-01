#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

APP_RAKEFILE = File.expand_path("../test/testapp/Rakefile", __FILE__)
puts APP_RAKEFILE
load 'rails/tasks/engine.rake'

require 'rake/testtask'
task :default => :test

desc 'Runs test:units, test:functionals'
task :test do
  tests_to_run = %w(test:units test:functionals)
  errors = tests_to_run.collect do |task|
    begin
      Rake::Task[task].invoke
      nil
    rescue => e
      task
    end
  end.compact
  abort "Errors running #{errors * ', '}!" if errors.any?
end

namespace :test do

  Rake::TestTask.new(:functionals) do |t|
    t.libs << "lib"
    t.libs << "test"
    t.pattern = 'test/functional/**/*_test.rb'
    t.verbose = true
  end
  
  Rake::TestTask.new(:units) do |t|
    t.libs << "lib"
    t.libs << "test"
    t.pattern = 'test/unit/**/*_test.rb'
    t.verbose = true    
  end  
  
end

begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name = "community_engine"
    gem.summary = "CommunityEngine for Rails 3"
    gem.email = 'admin@curbly.com'
    gem.authors = ["Bruno Bornsztein"]    
    gem.version = File.read('VERSION')
    
    gem.add_dependency 'rails', '3.1.0'
    gem.add_dependency 'rack', '1.3.2'    
    gem.add_dependency 'arel', '~> 2.2.1'        

    gem.add_dependency 'authlogic'
    gem.add_dependency 'configatron'
    gem.add_dependency 'hpricot'
    gem.add_dependency 'htmlentities'
    gem.add_dependency 'haml'
    gem.add_dependency 'calendar_date_select'
    gem.add_dependency 'ri_cal'
    gem.add_dependency 'rakismet'
    gem.add_dependency 'aws-s3'
    gem.add_dependency 'kaminari'
    gem.add_dependency "dynamic_form"
    gem.add_dependency "friendly_id", "3.2.1"
    gem.add_dependency "paperclip", "~> 2.3"
    gem.add_dependency 'acts_as_commentable', '~> 3.0.0'    
    gem.add_dependency 'recaptcha'
    gem.add_dependency 'simplecov'
    gem.add_dependency 'omniauth', '~> 0.2.6'
    gem.add_dependency 'prototype-rails'
    gem.add_dependency 'rails_autolink'
    gem.add_dependency 'meta_search', '1.1.0.pre2'   
  end
rescue
  puts "Jeweler or one of its dependencies is not installed."
end
