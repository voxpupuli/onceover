require 'onceover/logger'
include Onceover::Logger

class Onceover
  # Manages litmus things
  class Litmus
    def initialize(opts = {})
      Onceover::Litmus.require!

      @root     = opts[:root]     || Dir.pwd
      @rakefile = opts[:rakefile] || "#{@root}/Rakefile"

      log.debug "Telling rake to load the ganerated Rakefile at: #{@rakefile}"
      load_rakefile(@rakefile)

      # Loading the Rakefile causes iessues with logging that need to be reset
      log_reset_appenders!
    end

    # Creates a node, this should also set the litmus details within the node object
    # and return the object itself
    def up(node)
      log.debug "Provisioning #{node.name} using litmus"

      cd do
        node.inventory_object = inventory_diff do
          Rake::Task['litmus:provision'].invoke(node.provisioner, node.image)
          Rake::Task['litmus:provision'].reenable
        end
      end
    end

    def down(node)
      log.debug "Destroying #{node.name} using litmus"

      cd do
        Rake::Task['litmus:tear_down'].invoke(node.litmus_name)
        Rake::Task['litmus:tear_down'].reenable
      end
    end

    # Chnages to the correct doretory for running all commands
    def cd
      Dir.chdir(@root) do
        yield
      end
    end

    # Gracefully load eveything we need to run litmus
    def self.require!
      begin
        log.debug "Loading Litmus"
        require 'puppet_litmus'
        require 'rake'
        require 'puppet_litmus/rake_tasks'
        require 'puppetlabs_spec_helper/rake_tasks'  
      rescue LoadError => e
        log.error "Something went wrong loading Litmus, probably Litmus was not detected. Please add the following line to your gemfile:"
        log.error "gem 'puppet_litmus"
        log.error "Note that this requires Puppet >= 6 and will cause dependency issues if you are using an older version of Puppet"
        throw e
      end
    end

    def inventory
      require 'yaml'
      require 'bolt'

      Bolt::Inventory.new(YAML.safe_load(File.read("#{@root}/inventory.yaml")))
    end

    def inventory_diff
      # Capture the nodes before and after
      before_nodes = extract_all_nodes(inventory)
      yield
      after_nodes = extract_all_nodes(inventory)
 
      # Remove all old values
      before_nodes.each do |name, details|
        after_nodes.delete(name)
      end

      after_nodes
    end

    private

    def load_rakefile(file)
      # Don't reload if it's already done
      return nil if Rake::Task.tasks.any? { |t| t.name == 'litmus:provision'}

      Rake.load_rakefile(file)
    end

    # Extracts a flat list of nodes from an inventory
    def extract_all_nodes(inventory)
      nodes = {}

      inventory.collect_groups.each do |name, group|
        nodes.merge!(group.nodes)
      end

      nodes
    end
  end
end
