# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "awesome_usps/version"

Gem::Specification.new do |s|
  s.name        = "awesome-usps"
  s.version     = AwesomeUSPS::VERSION
  s.authors     = ["Matthew Bergman", "Wes Morgan"]
  s.email       = ["mzbphoto@gmail.com", "wes@turbovote.org"]
  s.homepage    = "https://github.com/FotoVerite/awesome-usps"
  s.summary     = %q{awesome-usps is a Ruby wrapper around the USPS web API}
  s.description = %q{A ruby wrapper around the various USPS APIs for generating rates, tracking information, label generation, and address checking.}

  s.rubyforge_project = "awesome-usps"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "hpricot"

  s.add_development_dependency "mocha"
end
