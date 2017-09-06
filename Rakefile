require 'rubygems/tasks'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
Gem::Tasks.new

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--pattern spec/\*/\*_spec.rb'
end

Cucumber::Rake::Task.new

task default: :full_tests

desc "Run full set of tests"
task full_tests: [:unit_tests, :acceptance_tests]

desc "Run unit tests"
task unit_tests: [:syntax, :rubocop, :fixtures, :spec]

desc "Run acceptance tests"
task acceptance_tests: [:syntax, :rubocop, :cucumber]

task :syntax do
  paths = ['lib',]
  require 'find'
  Find.find(*paths) do |path|
    next unless path =~ /\.rb$/
    sh "ruby -cw #{path} > /dev/null"
  end
end

task :rubocop do
  require 'rubocop'
  cli = RuboCop::CLI.new
  exit_code = cli.run(%w(--display-cop-names --format simple))
  raise "RuboCop detected offenses" if exit_code != 0
end

task :fixtures do
  system 'git submodule init && git submodule update --recursive'
  raise "Couldn't clone controlrepo to fixtures directory" unless $?.success?
end

