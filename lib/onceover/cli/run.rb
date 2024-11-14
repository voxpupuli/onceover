require 'cri'
require 'onceover/controlrepo'
require 'onceover/cli'
require 'onceover/runner'
require 'onceover/testconfig'
require 'onceover/logger'
require 'onceover/deploy'

class Onceover
  class CLI
    class Run
      def self.command
        @command ||= Cri::Command.define do
          name 'run'
          usage 'run [spec|acceptance]'
          summary 'Runs either the spec or acceptance tests'
          description <<-DESCRIPTION
This will run the full set of spec or acceptance tests.
This includes deploying using r10k and running all custom tests.
          DESCRIPTION

          optional :t,  :tags,             'A list of tags. Only tests with these tags will be run'
          optional :c,  :classes,          'A list of classes. Only tests with these classes will be run'
          optional :n,  :nodes,            'A list of nodes. Only tests with these nodes will be run'
          optional :s,  :skip_r10k,        'Skip the r10k step'
          optional :f,  :force,            'Passes --force to r10k, overwriting modules'
          optional :sv, :strict_variables, 'Run with strict_variables set to yes'

          run do |opts, args, cmd|
            puts cmd.help(:verbose => opts[:verbose])
            exit 0
          end
        end
      end

      class Spec
        def self.command
          @command ||= Cri::Command.define do
            name 'spec'
            usage 'spec'
            summary 'Runs spec tests'

            optional :p, :parallel, 'Runs spec tests in parallel. This increases speed at the cost of poorly formatted logs and irrelevant junit output.'
            optional nil, :format, 'Which RSpec formatter to use, valid options are: documentation, progress, FailureCollector, OnceoverFormatter. You also specify this multiple times', multiple: true, default: :defaults
            optional nil, :no_workarounds, 'Disables workarounds that have been added for convenience to get around common RSPec issues such as https://github.com/rodjek/rspec-puppet/issues/665'
            optional :ff, :fail_fast, 'Abort the run after the first failure'
            optional nil, :auto_vendored, 'Attempt to resolve vendored puppet modules. Ex: puppetlabs/cron_core', default: false

            run do |opts, args, cmd|
              repo = Onceover::Controlrepo.new(opts)
              Onceover::Deploy.new.deploy_local(repo, opts)
              runner = Onceover::Runner.new(repo,Onceover::TestConfig.new(repo.onceover_yaml, opts), :spec)
              runner.prepare!
              runner.run_spec!
            end
          end
        end
      end

      class Acceptance
        def self.command
          @command ||= Cri::Command.define do
            name 'acceptance'
            usage 'acceptance'
            summary 'Runs acceptance tests'

            run do |opts, args, cmd|
              warn "[DEPRECATION] Acceptance testing is deprecated due to the removal of Beaker dependencies"
              warn "[DEPRECATION] Appeptance testing will be replaced by a more pluggable framework in the future, if you have ideas as to how this should be done please submit a ticket."
              repo = Onceover::Controlrepo.new(opts)
              runner = Onceover::Runner.new(repo,Onceover::TestConfig.new(repo.onceover_yaml,opts), :acceptance)
              runner.prepare!
              runner.run_acceptance!
            end
          end
        end
      end
    end
  end
end

# Register itself
Onceover::CLI.command.add_command(Onceover::CLI::Run.command)
Onceover::CLI::Run.command.add_command(Onceover::CLI::Run::Spec.command)
Onceover::CLI::Run.command.add_command(Onceover::CLI::Run::Acceptance.command)
