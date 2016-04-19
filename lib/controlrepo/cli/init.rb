require 'cri'
require 'controlrepo'
require 'controlrepo/cli'
require 'controlrepo/runner'
require 'controlrepo/testconfig'
require 'controlrepo/logger'

class Controlrepo
  class CLI
    class Init
      def self.command
        @cmd ||= Cri::Command.define do
          name 'init'
          usage 'init'
          summary 'Sets up a controlrepo for testing from scratch'
          description <<-DESCRIPTION
This will generate all of the config files required for the controlrepo
tool to work.
          DESCRIPTION

          run do |opts, args, cmd|
            Controlrepo::Logger.logger.level = :debug if opts[:debug]
            Controlrepo.init(Controlrepo.new(opts))
          end
        end
      end
    end
  end
end

# Register itself
Controlrepo::CLI.command.add_command(Controlrepo::CLI::Init.command)
