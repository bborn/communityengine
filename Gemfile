source 'http://rubygems.org'

gem 'omniauth-facebook'
gem 'acts_as_commentable', :git => 'https://github.com/jackdempsey/acts_as_commentable.git'

group :test do
  gem 'sqlite3'
  gem 'mocha', :require => false
end

rails_version = ENV["RAILS_VERSION"] || "default"

rails = case rails_version
when "master"
  {github: "rails/rails"}
when "default"
  ">= 3.2.0"
else
  "~> #{rails_version}"
end

gem "rails", rails


gemspec
