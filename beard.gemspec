# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'beard/version'

Gem::Specification.new do |spec|
  spec.name          = 'Beard'
  spec.version       = Beard::VERSION
  spec.licenses      = ['MIT']
  spec.authors       = ['Joe Osburn']
  spec.email         = ['joe@jnodev.com']

  spec.summary       = 'Ruby version of beard'
  spec.homepage      = 'https://github.com/joeosburn/ruby-beard'
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']
  spec.test_files = Dir['spec/**/*']

  # spec.add_dependency 'eventmachine', '~> 1.2',

  spec.add_development_dependency 'rspec', '~> 3.9.0'
end
