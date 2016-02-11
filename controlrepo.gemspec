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
  s.add_runtime_dependency 'rake'
  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'beaker-rspec'
  s.add_runtime_dependency 'rspec-puppet'
  s.add_runtime_dependency 'puppetlabs_spec_helper'
  s.add_runtime_dependency 'rspec'
  s.add_runtime_dependency 'bundler'
  s.add_runtime_dependency 'r10k'
  s.add_runtime_dependency 'puppet'
  s.add_runtime_dependency 'git'
  s.add_runtime_dependency 'vagrant-wrapper'
end
