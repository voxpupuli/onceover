# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "controlrepo"
  s.version     = "0.0.1"
  s.authors     = ["Dylan Ratcliffe"]
  s.email       = ["dylan.ratcliffe@puppetlabs.com"]
  s.homepage    = ""
  s.summary     = ""
  s.description = ""
  s.licenses    = 'Apache-2.0'

  s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  # Runtime dependencies, but also probably dependencies of requiring projects
  s.add_runtime_dependency 'rake'
  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'puppet'

end