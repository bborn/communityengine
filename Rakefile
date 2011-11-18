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