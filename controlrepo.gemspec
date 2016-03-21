# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "controlrepo"
  s.version     = "2.0.8"
  s.authors     = ["Dylan Ratcliffe"]
  s.email       = ["dylan.ratcliffe@puppetlabs.com"]
  s.homepage    = "https://github.com/dylanratcliffe/controlrepo_gem"
  s.summary     = "Testing tools for Puppet controlrepos"
  s.description = "Testing tools for Puppet controlrepos"
  s.licenses    = 'Apache-2.0'

  s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  # Runtime dependencies, but also probably dependencies of requiring projects
  s.add_runtime_dependency 'rake', '>= 10.0.0'
  s.add_runtime_dependency 'json', '>= 1.8.2'
  s.add_runtime_dependency 'beaker-rspec'
  s.add_runtime_dependency 'rspec-puppet' # TODO: This needs to be updated once the relese is tagged
  s.add_runtime_dependency 'puppetlabs_spec_helper', ">= 0.4.0"
  s.add_runtime_dependency 'rspec', '>= 3.0.0'
  s.add_runtime_dependency 'bundler'
  s.add_runtime_dependency 'r10k', '>=2.1.0'
  s.add_runtime_dependency 'puppet'
  s.add_runtime_dependency 'git'
end
