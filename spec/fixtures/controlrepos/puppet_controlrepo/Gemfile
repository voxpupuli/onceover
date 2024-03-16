source 'https://rubygems.org'

group :development do
  gem 'pry'
  gem 'pry-byebug'
  gem 'rb-readline'
  gem 'puppet-debugger'
end

if ENV['ONCEOVER_gem'] == 'local'
  gem 'onceover', :path => '/Users/dylan/git/onceover'
#  gem 'onceover-octocatalog-diff', :path => '/Users/dylan/git/onceover-octocatalog-diff'
else
  gem 'onceover', :git => 'https://github.com/dylanratcliffe/onceover.git'#, :branch => 'issue-51'
#  gem 'onceover-octocatalog-diff', :git => 'https://github.com/dylanratcliffe/onceover-octocatalog-diff.git'
end

gem 'hiera-eyaml'
gem 'puppet', ENV['PUPPET_version'] || '~> 8'

# Require by telegraf module
gem 'toml-rb'
