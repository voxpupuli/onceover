require 'cri'
require 'onceover/controlrepo'
require 'onceover/cli'
require 'onceover/logger'

class Onceover
  class CLI
    class Show
      def self.command
        @cmd ||= Cri::Command.define do
          name 'show'
          usage 'show [controlrepo|puppetfile]'
          summary 'Shows the current state things'
          description <<-DESCRIPTION
Shows the state of either the controlrepo or the Puppetfile
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
              puts Onceover::Controlrepo.new(opts).to_s
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
Shows the state of the puppetfile including current versions and
laetst versions of each module. Great for checking for updates.
To update all modules run `onceover update puppetfile`. (Hint: once
you have done the update, run the tests to make sure nothing breaks.)
            DESCRIPTION

            run do |opts, args, cmd|
              # Print out the description
              Onceover::Controlrepo.new(opts).print_puppetfile_table
              exit 0
            end
          end
        end
      end
    end
  end
end

# Register itself
Onceover::CLI.command.add_command(Onceover::CLI::Show.command)
Onceover::CLI::Show.command.add_command(Onceover::CLI::Show::Repo.command)
Onceover::CLI::Show.command.add_command(Onceover::CLI::Show::Puppetfile.command)
