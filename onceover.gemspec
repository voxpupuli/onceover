# -*- encoding: utf-8 -*-

$LOAD_PATH.unshift File.expand_path('lib', __dir__)

Gem::Specification.new do |s| # rubocop:disable Gemspec/RequireMFA
  s.name        = "onceover"
  s.version     = "3.22.0"
  s.authors     = ["Dylan Ratcliffe"]
  s.email       = ["dylan.ratcliffe@puppet.com"]
  s.homepage    = "https://github.com/dylanratcliffe/onceover"
  s.summary     = "Testing tools for Puppet controlrepos"
  s.description = "Automatically generates tests for your Puppet code"
  s.licenses    = 'Apache-2.0'

  s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.bindir       = 'bin'
  s.executables  = 'onceover'

  # Runtime dependencies, but also probably dependencies of requiring projects
  s.add_runtime_dependency 'backticks', '>= 1.0.2'
  s.add_runtime_dependency 'colored', '>= 1.2'
  s.add_runtime_dependency 'cri', '>= 2.6'
  s.add_runtime_dependency 'deep_merge', '>= 1.0.0'
  s.add_runtime_dependency 'git'
  s.add_runtime_dependency 'logging', '>= 2.0.0'
  s.add_runtime_dependency 'multi_json', '>= 1.10'
  s.add_runtime_dependency 'parallel_tests', ">= 2.0.0"
  s.add_runtime_dependency 'puppet', '>=4.0'
  s.add_runtime_dependency 'puppetlabs_spec_helper', ">= 0.4.0"
  s.add_runtime_dependency 'r10k', '>=2.1.0'
  s.add_runtime_dependency 'rake', '>= 10.0.0'
  s.add_runtime_dependency 'rspec', '>= 3.0.0'
  s.add_runtime_dependency 'rspec_junit_formatter', '>= 0.2.0'
  s.add_runtime_dependency 'rspec-puppet', ">= 2.4.0"
  s.add_runtime_dependency 'terminal-table', '>= 1.8.0'
  s.add_runtime_dependency 'versionomy', '>= 0.5.0'
end
