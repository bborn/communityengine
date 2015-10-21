# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'community_engine/version'

Gem::Specification.new do |s|
  s.name        = "community_engine"
  s.version     = CommunityEngine::Version::STRING
  s.summary     = "CommunityEngine for Rails 4"
  s.description = "CommunityEngine is a free, open-source social network platform for Ruby on Rails applications. Drop it into your new or existing application, and you’ll instantly have all the features of a basic community site."
  s.homepage    = "http://www.communityengine.org"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors          = ["Bruno Bornsztein"]
  s.email            = "admin@curbly.com"
  s.extra_rdoc_files = [
      "LICENSE",
      "README.markdown"
  ]
  s.require_paths    = ["lib"]
  s.rubygems_version = "1.8.11"
  s.licenses = ["MIT", "see each plugin"]

  s.files = `git ls-files`.split("\n") rescue ''
  s.test_files = `git ls-files -- {test}/*`.split("\n")

  s.add_dependency "activeadmin",               "~> 1.0.0.pre1"
  s.add_dependency "pundit",                    "0.3.0"
  s.add_dependency "actionpack-action_caching", ">= 0"
  s.add_dependency "actionpack-page_caching",   ">= 0"
  s.add_dependency "acts_as_commentable",       "~> 4.0.2"
  s.add_dependency "acts_as_list",              ">= 0.3.0"
  s.add_dependency "acts-as-taggable-on",       '~> 3.4.4'
  s.add_dependency "authlogic",                 ">= 3.3.0"
  s.add_dependency "aws-sdk",                   "< 2.0"
  s.add_dependency "bcrypt",                    ">= 0"
  s.add_dependency "cocaine",                   "~> 0.5.1"
  s.add_dependency "configatron",               "~> 4.2.0"
  s.add_dependency "dynamic_form",              ">= 0"
  s.add_dependency "friendly_id",               "~> 5.0.0.beta1"
  s.add_dependency "haml",                      ">= 0"
  s.add_dependency "hpricot",                   ">= 0"
  s.add_dependency "htmlentities",              ">= 0"
  s.add_dependency "kaminari",                  ">= 0"
  s.add_dependency "koala",                     "~> 1.6.0"
  s.add_dependency "omniauth",                  "~> 1.1.4"
  s.add_dependency "rails_autolink",            ">= 0"
  s.add_dependency "paperclip",                 "~> 4.2.0"
  s.add_dependency "power_enum",                "~> 2.7"
  s.add_dependency "rack",                      ">= 1.5.2"
  s.add_dependency "rails",                     "~> 4.1.0"
  s.add_dependency "rails-observers",           ">= 0"
  s.add_dependency "rakismet",                  ">= 0"
  s.add_dependency "ransack",                   "~> 1.6.3"
  s.add_dependency "recaptcha",                 ">= 0"
  s.add_dependency "ri_cal",                    ">= 0"
  s.add_dependency "sanitize",                  ">= 2.0.6"
  s.add_dependency "bootstrap-sass",            '~> 3.2.0'
  s.add_dependency "bootstrap_form",            ">= 0"
  s.add_dependency "font-awesome-rails",        ">= 0"
  s.add_dependency "jquery-rails",              ">= 0"
  s.add_dependency "jquery-ui-rails",           "~> 5.0.0"
  s.add_dependency "jquery-turbolinks"
  s.add_dependency "turbolinks"
  s.add_dependency "sass-rails",                "~> 4.0.0"
  s.add_dependency "sprockets",                 "~> 2.10.0"
  s.add_dependency "ckeditor",                  "~> 4.1.1"
end

