require 'cri'

class Controlrepo
  class CLI
    def self.command
      @cmd ||= Cri::Command.define do
        name 'controlrepo'
        usage 'controlrepo <subcommand> [options]'
        summary 'Tool for testing Puppet controlrepos'

        flag :h, :help, 'Show help for this command' do |value, cmd|
          puts cmd.help
          exit 0
        end

        flag :t, :trace, 'Display stack traces on application crash'
        optional :p, :path, 'Path to the root of the controlrepo'

        run do |opts, args, cmd|
          puts cmd.help(:verbose => opts[:verbose])
          exit 0
        end
      end
    end
  end
end
