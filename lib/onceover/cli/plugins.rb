require 'rubygems'

# Get all of the gems that start with onceover-
plugins = Gem::Specification.group_by{ |g| g.name }.keep_if do |name, details|
  name =~ /^onceover-.*$/
end.keys

plugins.each do |plugin|
  require plugin.gsub('-', '/')
end
