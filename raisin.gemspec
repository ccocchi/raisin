# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'raisin/version'

Gem::Specification.new do |s|
  s.name          = "raisin"
  s.version       = Raisin::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["ccocchi"]
  s.email         = ["cocchi.c@gmail.com"]
  s.description   = %q{API versioning via the Accept header}
  s.summary       = %q{Build API with Accept header versioning on top of Rails}
  s.homepage      = "https://github.com/ccocchi/raisin"
  s.license       = 'MIT'

  s.required_ruby_version     = '>= 2.2.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency 'actionpack', '~> 5.0'
  s.add_dependency 'activesupport', '~> 5.0'
end
