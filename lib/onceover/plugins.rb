require 'rubygems'

class Onceover
  class Plugins
    attr_reader :plugins

    def initialize
      # Get all of the gems that start with onceover-
      @plugins = Gem::Specification.group_by{ |g| g.name }.keep_if do |name,details|
        name =~ /^onceover-.*$/
      end
    end

    def load!
      @plugins.keys.each do |plugin|
        require plugin.gsub('-','/')
      end
    end
  end
end
