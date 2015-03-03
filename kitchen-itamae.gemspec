# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen-itamae/version'

Gem::Specification.new do |spec|
  spec.name          = "kitchen-itamae"
  spec.version       = Kitchen::Itamae::VERSION
  spec.authors       = ["sawanoboly"]
  spec.email         = ["sawanoboriyu@higanworks.com"]
  spec.summary       = %q{itamae provisioner for test-kitchen}
  spec.description   = %q{itamae provisioner for test-kitchen}
  spec.homepage      = "https://github.com/OpsRockin/kitchen-itamae"
  spec.license       = "apache2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "test-kitchen"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard-rspec"
end
