# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'syslog/server'

Gem::Specification.new do |spec|
  spec.name          = 'syslog-server'
  spec.version       = Syslog::Server::VERSION
  spec.authors       = ['Chris Davies']
  spec.email         = ['chris.davies.uk@member.mensa.org']
  spec.summary       = %q{A syslog server toolkit.}
  spec.description   = %q{A syslog server toolkit.}
  spec.homepage      = 'https://github.com/north636/syslog-server'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
end
