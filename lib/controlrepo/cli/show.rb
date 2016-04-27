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
          usage 'show [controlrepo|puppetfile]'
          summary 'Shows the current state things'
          description <<-DESCRIPTION
Shows the state of the controlrepo as the tool sees it.
Useful for debugging.
          DESCRIPTION

          run do |opts, args, cmd|
            # Print out the description
            puts cmd.help(:verbose => opts[:verbose])
            exit 0
          end
        end
      end

      class Repo
        def self.command
          @cmd ||= Cri::Command.define do
            name 'repo'
            usage 'repo [options]'
            summary 'Shows the current state of the Controlrepo'
            description <<-DESCRIPTION
  Shows the state of the repo as the tool sees it.
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

      class Puppetfile
        def self.command
          @cmd ||= Cri::Command.define do
            name 'puppetfile'
            usage 'puppetfile [options]'
            summary 'Shows the current state of the puppetfile'
            description <<-DESCRIPTION
  Shows the state of the puppetfile as the tool sees it.
  Useful for debugging.
            DESCRIPTION

            run do |opts, args, cmd|
              # Print out the description
              Controlrepo.new(opts).print_puppetfile_table
              exit 0
            end
          end
        end
      end
    end
  end
end

# Register itself
Controlrepo::CLI.command.add_command(Controlrepo::CLI::Show.command)
Controlrepo::CLI::Show.command.add_command(Controlrepo::CLI::Show::Repo.command)
Controlrepo::CLI::Show.command.add_command(Controlrepo::CLI::Show::Puppetfile.command)
