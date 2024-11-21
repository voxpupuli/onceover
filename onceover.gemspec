# -*- encoding: utf-8 -*-

$LOAD_PATH.unshift File.expand_path('lib', __dir__)

Gem::Specification.new do |s| # rubocop:disable Gemspec/RequireMFA
  s.name        = "onceover"
  s.version     = "4.0.0"
  s.authors     = ["Dylan Ratcliffe", 'Vox Pupuli']
  s.email       = ["voxpupuli@groups.io"]
  s.homepage    = "https://github.com/voxpupuli/onceover"
  s.summary     = "Testing tools for Puppet controlrepos"
  s.description = "Automatically generates tests for your Puppet code"
  s.licenses    = 'Apache-2.0'

  s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.bindir       = 'bin'
  s.executables  = 'onceover'

  s.required_ruby_version = Gem::Requirement.new('>= 2.7')

  # Runtime dependencies, but also probably dependencies of requiring projects
  s.add_dependency 'backticks', '>= 1.0.2'
  s.add_dependency 'colored', '>= 1.2'
  s.add_dependency 'cri', '>= 2.6'
  s.add_dependency 'deep_merge', '>= 1.0.0'
  s.add_dependency 'git'
  s.add_dependency 'logging', '>= 2.0.0'
  s.add_dependency 'multi_json', '>= 1.10'
  s.add_dependency 'parallel_tests', ">= 2.0.0"
  s.add_dependency 'puppet', '>=4.0'
  s.add_dependency 'puppetlabs_spec_helper', ">= 0.4.0"
  s.add_dependency 'r10k', '>=2.1.0'
  s.add_dependency 'rake', '>= 10.0.0'
  s.add_dependency 'rspec', '>= 3.0.0'
  s.add_dependency 'rspec_junit_formatter', '>= 0.2.0'
  s.add_dependency 'rspec-puppet', ">= 2.4.0"
  s.add_dependency 'terminal-table', '>= 1.8.0'
  s.add_dependency 'versionomy', '>= 0.5.0'
  s.add_development_dependency 'voxpupuli-rubocop', '~> 3.0.0'
end
