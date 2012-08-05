# -*- encoding: utf-8 -*-
require File.expand_path('../lib/awesome_usps/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "awesome_usps"
  gem.platform      = Gem::Platform::RUBY
  gem.authors       = ['Matthew Bergman', 'David Ryder', 'Alex Bisignano']
  gem.email         = ['mzbphoto@gmail.com', 'david@libryder.com', 'alex@alx.bz']
  gem.homepage      = "http://rubygems.org/gems/awesome_usps"
  gem.summary       = "A ruby wrapper around the various USPS APIs for generating rates, tracking information, label generation, and address checking."
  gem.description   = "To provide easy access to the USPS API"
  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths  = ['lib']

  gem.add_dependency(%q<nokogiri>)
  gem.add_development_dependency('rspec', [">= 2.0.0"])

  gem.version       = AwesomeUsps::VERSION
end