require 'cri'
require 'controlrepo'
require 'controlrepo/cli'
require 'controlrepo/runner'
require 'controlrepo/testconfig'
require 'controlrepo/logger'

class Controlrepo
  class CLI
    class Run
      def self.command
        @cmd ||= Cri::Command.define do
          name 'run'
          usage 'run [spec|acceptance]'
          summary 'Runs either the spec or acceptance tests'
          description <<-DESCRIPTION
This will run the full set of spec or acceptance tests.
This includes deploying using r10k and running all custom tests.
          DESCRIPTION

          optional :t, :tags, 'A list of tags. Only tests with these tags will be run'

          run do |opts, args, cmd|
            puts cmd.help(:verbose => opts[:verbose])
            exit 0
          end
        end
      end

      class Spec
        def self.command
          @cmd ||= Cri::Command.define do
            name 'spec'
            usage 'spec'
            summary 'Runs spec tests'

            run do |opts, args, cmd|
              repo = Controlrepo.new(opts)
              runner = Controlrepo::Runner.new(repo,Controlrepo::TestConfig.new(repo.controlrepo_yaml,opts),:spec)
              runner.prepare!
              runner.run_spec!
            end
          end
        end
      end

      class Acceptance
        def self.command
          @cmd ||= Cri::Command.define do
            name 'acceptance'
            usage 'acceptance'
            summary 'Runs acceptance tests'

            run do |opts, args, cmd|
              repo = Controlrepo.new(opts)
              runner = Controlrepo::Runner.new(repo,Controlrepo::TestConfig.new(repo.controlrepo_yaml,opts),:acceptance)
              runner.prepare!
              runner.run_spec!
            end
          end
        end
      end
    end
  end
end

# Register itself
Controlrepo::CLI.command.add_command(Controlrepo::CLI::Run.command)
Controlrepo::CLI::Run.command.add_command(Controlrepo::CLI::Run::Spec.command)
Controlrepo::CLI::Run.command.add_command(Controlrepo::CLI::Run::Acceptance.command)
