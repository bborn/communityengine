# -*- coding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = "tiny_mce"
  s.version = "0.1.7"
  s.authors = ["Blake Watters", "Kieran Pilkington", "Sergio Cambra", "Alexander Semyonov", "Marian Theisen", "Walter McGinnis", "Frederico Macedo de Assunção", "Josh Proehl", "Sasha Gerrand"]
  s.email = "kete@katipo.co.nz"
  s.homepage = "http://github.com/kete/tiny_mce"
  s.summary = "TinyMCE editor for your rails applications."
  s.description = "Gem that allows easy implementation of the TinyMCE editor into your applications."

  s.files = Dir["lib/**/*", "[A-Z]*", "init.rb", "install.rb", "tiny_mce.gemspec"]
  s.test_files = Dir["test/**/*"]
  s.require_path = "lib"

  s.extra_rdoc_files = Dir["*.rdoc"]
  s.rdoc_options = ["--charset=UTF-8", "--exclude=lib/tiny_mce/assets"]
end
