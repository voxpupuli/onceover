require 'cri'

class Onceover
  class CLI
    def self.command
      @cmd ||= Cri::Command.define do
        name 'onceover'
        usage 'onceover <subcommand> [options]'
        summary 'Tool for testing Puppet controlrepos'

        flag :h, :help, 'Show help for this command' do |value, cmd|
          puts cmd.help
          exit 0
        end

        flag nil, :trace, 'Display stack traces on application crash'
        flag :d, :debug, 'Enable debug logging'
        optional :p, :path, 'Path to the root of the controlrepo'
        optional nil, :environmentpath, 'Value of environmentpath from puppet.conf'
        optional nil, :puppetfile, 'Location of the Puppetfile'
        optional nil, :environment_conf, 'Location of environment.con'
        optional nil, :facts_dir, 'Directory in which to find factsets'
        optional nil, :spec_dir, 'Directory in which to find spec tests and config'
        optional nil, :facts_files, 'List of factset files to use (Overrides --facts_dir)'
        optional nil, :nodeset_file, 'YAML file containing node definitions'
        optional nil, :tempdir, 'Temp directory to use, defaults to .controlrepo'
        optional nil, :manifest, 'Path fo find manifests'
        optional nil, :onceover_yaml, 'Path of controlrepo.yaml'

        run do |opts, args, cmd|
          puts cmd.help(:verbose => opts[:verbose])
          exit 0
        end
      end
    end

    # Add the help
    Onceover::CLI.command.add_command(Cri::Command.new_basic_help)
  end
end

# Add all of the other CLI components
require 'onceover/cli/show'
require 'onceover/cli/run'
require 'onceover/cli/init'
require 'onceover/cli/update'
require 'onceover/cli/plugins'
