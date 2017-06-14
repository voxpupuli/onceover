require 'rubygems'

class Onceover
  class Plugins
    attr_reader :plugins

    def initialize
      # Get all of the gems that start with onceover-
      @plugins = Gem::Specification.group_by{ |g| g.name }.keep_if do |name,details|
        name =~ /^onceover-.*$/
      end.keys
    end

    def load!
      @plugins.each do |plugin|
        require plugin.gsub('-','/')
      end
    end
  end
end

# Always make sure all the plugins are loaded
Onceover::Plugins.new.load!
