# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'community_engine/version'


Gem::Specification.new do |s|
  s.name = "community_engine"
  s.version = CommunityEngine::Version::STRING
  s.summary = "CommunityEngine for Rails 3"  
  s.description = "CommunityEngine is a free, open-source social network platform for Ruby on Rails applications. Drop it into your new or existing application, and you’ll instantly have all the features of a basic community site."
  s.homepage = "http://www.communityengine.org"
  
  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bruno Bornsztein"]
  s.date = "2011-11-18"
  s.email = "admin@curbly.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.markdown"
  ]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.11"
  
  s.files       = `git ls-files`.split("\n") rescue ''
  s.test_files  = `git ls-files -- {test}/*`.split("\n")  
  
  s.add_dependency(%q<rails>, ["= 3.2.0"])
  s.add_dependency(%q<rack>, [">= 1.4.1"])  
  s.add_dependency(%q<authlogic>, [">= 0"])
  s.add_dependency(%q<bcrypt-ruby>, [">= 0"])
  s.add_dependency(%q<configatron>, [">= 0"])
  s.add_dependency(%q<hpricot>, [">= 0"])
  s.add_dependency(%q<htmlentities>, [">= 0"])
  s.add_dependency(%q<haml>, [">= 0"])
  s.add_dependency(%q<sass-rails>, ["~> 3.2.3"])
  s.add_dependency(%q<ri_cal>, [">= 0"])
  s.add_dependency(%q<rakismet>, [">= 0"])
  s.add_dependency(%q<aws-s3>, [">= 0"])
  s.add_dependency(%q<kaminari>, [">= 0"])
  s.add_dependency(%q<dynamic_form>, [">= 0"])
  s.add_dependency(%q<friendly_id>, ["~> 3.3"])
  s.add_dependency(%q<paperclip>, ["~> 2.4.3"])
  s.add_dependency(%q<acts_as_commentable>, ["= 3.0.1"])
  s.add_dependency(%q<recaptcha>, [">= 0"])
  s.add_dependency(%q<omniauth>, ["= 0.3.2"])
  s.add_dependency(%q<prototype-rails>, [">= 0"])
  s.add_dependency(%q<rails_autolink>, [">= 0"])
  s.add_dependency(%q<meta_search>, ["= 1.1.3"])
  s.add_dependency(%q<koala>, [">= 0"])
  s.add_dependency(%q<tinymce-rails>, ["~> 3.4.7"])
  s.add_dependency(%q<bborn-acts-as-taggable-on>, ['~> 2.2.1'])
  s.add_dependency(%q<sanitize>, [">= 2.0.3"])
end

