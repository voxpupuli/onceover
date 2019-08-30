require 'rubygems/tasks'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
Gem::Tasks.new

def windows?
  # Ruby only sets File::ALT_SEPARATOR on Windows and the Ruby standard
  # library uses that to test what platform it's on.
  !!File::ALT_SEPARATOR
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--pattern spec/onceover/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.rspec_opts = '--pattern spec/acceptance/**/*_spec.rb'
end

Cucumber::Rake::Task.new(:cucumber) do |t|
  require 'puppet'
  current = SemanticPuppet::Version.parse(Puppet.version)
  six     = SemanticPuppet::Version.parse('6.0.0')

  if current <= six
    tags = '--tags ~@acceptance'
  end
  
  t.cucumber_opts = "--format pretty #{tags}"
end

task default: :full_tests


desc "Run unit tests"
task rspec_unit_tests: [:syntax, :rubocop, :spec]

desc "Run acceptance cucumber tests"
task cucumber_acceptance_tests: [:syntax, :rubocop, :fixtures, :cucumber]

desc "Run full set of tests"
task full_tests: [:rspec_unit_tests, :cucumber_acceptance_tests]

task :syntax do
  paths = ['lib', 'spec/onceover', 'features']
  require 'find'
  Find.find(*paths) do |path|
    next unless path =~ /\.rb$/
    if windows?
      sh "ruby -cw #{path} > NUL"
    else
      sh "ruby -cw #{path} > /dev/null"
    end
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
