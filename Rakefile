require 'rubygems/tasks'
require 'rspec/core/rake_task'
Gem::Tasks.new

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--pattern spec/\*/\*_spec.rb'
end

task default: :test

task test: [:syntax, :rubocop, :spec]

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
