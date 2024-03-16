require 'rubygems/tasks'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'rubocop/rake_task'
require 'puppet/version'
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

# Cucumber task that intelligently skips test tagged with a minimum puppet
# version in the format "@puppet6"
Cucumber::Rake::Task.new(:cucumber) do |t|
  major_version = Gem::Version.new(Puppet.version).segments[0]

  # Create a list of tags to skip based on the next 3 major versions
  skip_tags = ((major_version + 1)..(major_version + 3)).map { |v| "@puppet#{v}"}

  # Generate logic string
  skip_string = "not #{skip_tags.join(' and not ')}"

  t.cucumber_opts = "--tags \"#{skip_string}\"" # Any valid command line option can go here.
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

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options << '--display-cop-names'
  task.formatters = ['simple']
  task.patterns = [
    "lib/**/*.rb",
    "ext/**/*.rb",
  ]
end

task :fixtures do
  system 'git submodule init && git submodule update --recursive'
  raise "Couldn't clone controlrepo to fixtures directory" unless $?.success?
end
