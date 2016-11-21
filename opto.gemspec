# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opto/version'

Gem::Specification.new do |spec|
  spec.name          = "opto"
  spec.version       = Opto::VERSION
  spec.authors       = ["Kimmo Lehto"]
  spec.email         = ["info@kontena.io"]

  spec.summary       = "Create validatable and resolvable options from hashes"
  spec.description   = "Example: Opto.new(type: :string, name: 'foo, min_length: 20, from: { env: 'FOO' }).value"
  spec.homepage      = "https://github.com/kontena/opto"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
