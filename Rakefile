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
  controlrepo_dir = 'spec/fixtures/puppet_controlrepo'
  controlrepo_git_url = 'https://github.com/dylanratcliffe/puppet_controlrepo.git'
  FileUtils.remove_dir(controlrepo_dir)
  system "git clone #{controlrepo_git_url} #{controlrepo_dir}"
  raise "Couldn't clone controlrepo to fixtures directory" unless $?.success?
end

