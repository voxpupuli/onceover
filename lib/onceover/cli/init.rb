require 'cri'
require 'onceover/controlrepo'
require 'onceover/cli'
require 'onceover/runner'
require 'onceover/testconfig'
require 'onceover/logger'

class Onceover
  class CLI
    class Init
      def self.command
        @command ||= Cri::Command.define do
          name 'init'
          usage 'init'
          summary 'Sets up a controlrepo for testing from scratch'
          description <<-DESCRIPTION
This will generate all of the config files required for the onceover
tool to work.
          DESCRIPTION

          run do |opts, args, cmd|
            Onceover::Controlrepo.init(Onceover::Controlrepo.new(opts))
            # Would it make sense for #init to be a class instance method of Controlrepo ? Then you could:
            # cp = Onceover::Controlrepo.new(opts)
            # cp.init
          end
        end
      end
    end
  end
end

# Register itself
Onceover::CLI.command.add_command(Onceover::CLI::Init.command)
