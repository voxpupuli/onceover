require 'rubygems'

# Get all of the gems that start with onceover-
plugins = Gem::Specification.group_by{ |g| g.name }.keep_if do |name,details|
  name =~ /^onceover-.*$/
end.keys

plugins.each do |plugin|
  require plugin.gsub('-','/')
end

class Onceover
  class Plugins
    class Hooks
      # This runs before all tests, spec of acceptance
      def self.execute_pre_run

      end

      # This runs only before the beginning of spec tests
      def self.execute_pre_spec
        # Firstly run the pre_run hooks
        self.execute_pre_run
        self.execute_hook(:pre_spec)
      end

      def self.execute_pre_acceptance
        # Firstly run the pre_run hooks
        self.execute_pre_run
        self.execute_hook(:pre_acceptance)
      end

      def self.execute_hook(name)
        plugins.each do |plugin|
          binding.pry
        end
      end
    end
  end
end
