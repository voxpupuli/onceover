require 'rubygems/tasks'
require 'rspec/core/rake_task'
Gem::Tasks.new

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--pattern spec/\*/\*_spec.rb'
end

task default: :test

task test: [:syntax, :rubocop, :fixtures, :spec]

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
  clone_controlrepo_cmd = 'git clone https://github.com/dylanratcliffe/puppet_controlrepo.git spec/fixtures/puppet_controlrepo'
  system 'ls -al spec/fixtures'
  system 'ls -al spec/fixtures/puppet_controlrepo'
  unless File.directory?('spec/fixtures/puppet_controlrepo')
    system clone_controlrepo_cmd
    raise "Couldn't clone controlrepo to fixtures directory" unless $?.success?
  end
end

