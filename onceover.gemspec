# -*- encoding: utf-8 -*-

$LOAD_PATH.unshift File.expand_path('lib', __dir__)

Gem::Specification.new do |s| # rubocop:disable Gemspec/RequireMFA
  s.name        = "onceover"
  s.version     = "5.0.2"
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

  s.required_ruby_version = Gem::Requirement.new('>= 3.2')

  # Runtime dependencies, but also probably dependencies of requiring projects
  s.add_dependency 'backticks', '~> 1.0'
  s.add_dependency 'colored', '~> 1.2'
  s.add_dependency 'cri', '~> 2.6'
  s.add_dependency 'deep_merge', '~> 1.0'
  s.add_dependency 'git', '~> 4.0', '>= 4.0.5'
  s.add_dependency 'logging', '~> 2.0'
  s.add_dependency 'multi_json', '~> 1.10'
  s.add_dependency 'openvox', '~> 8.0'
  s.add_dependency 'parallel_tests', '~> 5.3'
  s.add_dependency 'r10k', '~> 5.0'
  s.add_dependency 'rake', '~> 13.3'
  s.add_dependency 'rspec', '~> 3.0'
  s.add_dependency 'rspec_junit_formatter', '~> 0.6'
  s.add_dependency 'rspec-puppet', '~> 5.0'
  s.add_dependency 'terminal-table', '~> 4.0'
  s.add_dependency 'versionomy', '~> 0.5'
  s.add_dependency 'voxpupuli-test', '~> 13.0'
end
