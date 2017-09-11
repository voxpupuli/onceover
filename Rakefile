require 'rubygems/tasks'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
Gem::Tasks.new

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--pattern spec/onceover/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.rspec_opts = '--pattern spec/acceptance/**/*_spec.rb'
end

Cucumber::Rake::Task.new

task default: :full_tests


desc "Run unit tests"
task rspec_unit_tests: [:syntax, :rubocop, :spec]

desc "Run acceptance cucumber tests"
task cucumber_acceptance_tests: [:syntax, :rubocop, :cucumber]

desc "Run acceptance rspec tests"
task rspec_acceptance_tests: [:syntax, :rubocop, :acceptance]

desc "Run full set of tests"
task full_tests: [:rspec_unit_tests, :rspec_acceptance_tests, :cucumber_acceptance_tests]

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
