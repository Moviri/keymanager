# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-keymanager/version'

Gem::Specification.new do |gem|
  gem.name          = 'vagrant-keymanager'
  gem.version       = VagrantPlugins::KeyManager::VERSION
  gem.authors       = ['Giorgio Baldaccini']
  gem.email         = ['giorgio.baldaccini@moviri.com']
  gem.description   = %q{A Vagrant plugin that manages SSH keys within a multi-machine environment}
  gem.summary       = gem.description
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'bundler', '~> 1.3'
  gem.add_development_dependency 'rake'
end
