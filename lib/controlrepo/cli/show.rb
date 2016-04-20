require 'cri'
require 'controlrepo'
require 'controlrepo/cli'
require 'controlrepo/logger'

class Controlrepo
  class CLI
    class Show
      def self.command
        @cmd ||= Cri::Command.define do
          name 'show'
          usage 'show [options]'
          summary 'Shows the current state of the Controlrepo'
          description <<-DESCRIPTION
Shows the state of the controlrepo as the tool sees it.
Useful for debugging.
          DESCRIPTION

          run do |opts, args, cmd|
            # Print out the description
            puts Controlrepo.new(opts).to_s
            exit 0
          end
        end
      end
    end
  end
end

# Register itself
Controlrepo::CLI.command.add_command(Controlrepo::CLI::Show.command)
