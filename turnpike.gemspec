# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'turnpike/version'

Gem::Specification.new do |s|
  s.name        = 'turnpike'
  s.version     = Turnpike::VERSION
  s.authors     = ['Hakan Ensari']
  s.email       = ['hakan.ensari@papercavalier.com']
  s.homepage    = 'http://github.com/hakanensari/turnpike'
  s.summary     = %q{A Redis-backed queue}
  s.description = %q{Turnpike is a Redis-backed queue.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'redis', '~> 3.0'
  s.add_development_dependency 'rake'
end
