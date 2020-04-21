source 'https://rubygems.org'

gemspec

gem 'pry-coolline', '> 0.0', '< 1.0.0'

if ENV['PUPPET_VERSION']
  gem 'puppet', ENV['PUPPET_VERSION']
end

# Evaluate Gemfile.local if it exists
if File.exist? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end

# Evaluate ~/.gemfile if it exists
if File.exist?(File.join(Dir.home, '.gemfile'))
  eval(File.read(File.join(Dir.home, '.gemfile')), binding)
end

if ENV['APPVEYOR'] == 'True'
  # R10k needs to be pinned to this until the next release after 3.1.1
  # in order to not have symlinks and therefor work on windows
  gem 'r10k', git: 'https://github.com/puppetlabs/r10k.git'
end

group :development do
  gem 'cucumber', '~> 2.0'
  gem 'pry', '~> 0.10.0'
  gem 'rubocop', '~> 0.82.0'
  gem 'rubygems-tasks', '~> 0.2.0'
end