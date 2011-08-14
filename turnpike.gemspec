# -*- encoding: utf-8 -*-
require "./lib/turnpike/version"

Gem::Specification.new do |s|
  s.name        = "turnpike"
  s.version     = Turnpike::VERSION
  s.authors     = ["Paper Cavalier"]
  s.email       = ["code@papercavalier.com"]
  s.homepage    = "http://code.papercavalier.com/turnpike"
  s.summary     = %q{A Redis-backed messaging queue}
  s.description = %q{Turnpike is a Redis-backed messaging queue.}

  s.rubyforge_project = "turnpike"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  {
    'redis'               => '~> 2.2'
  }.each do |lib, version|
    s.add_runtime_dependency lib, version
  end

  {
    'rake'                => '~> 0.9'
  }.each do |lib, version|
    s.add_development_dependency lib, version
  end
end
