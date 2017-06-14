require 'onceover/plugins'

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
        plugins = Onceover::Plugins.new.plugins
        binding.pry
      end
    end
  end
end
