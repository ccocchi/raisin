# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'raisin/version'

Gem::Specification.new do |gem|
  gem.name          = "raisin"
  gem.version       = Raisin::VERSION
  gem.authors       = ["ccocchi"]
  gem.email         = ["cocchi.c@gmail.com"]
  gem.description   = %q{TODO: An opiniated micro-framework to easily build API on top of Rails}
  gem.summary       = %q{TODO: An opiniated micro-framework to easily build API on top of Rails}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
