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
    # gem.files = Dir["{lib}/**/*", "{app}/**/*", "{config}/**/*", "{plugins}/**/*"]
    gem.version = '1.9.9'
    # gem.add_dependency 'hpricot'
    # gem.add_dependency 'configatron'        
    # other fields that would normally go in your gemspec
    # like authors, email and has_rdoc can also be included here

  end
rescue
  puts "Jeweler or one of its dependencies is not installed."
end