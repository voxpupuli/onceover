# Bolt needs to have a nice error if it doesn't work
require 'yaml'
require 'onceover/logger'
include Onceover::Logger

begin
  log.debug "Loading Bolt"
  require 'bolt'
  require 'bolt_spec/run'
rescue LoadError => e
  log.error "Something went wrong loading Bolt, probably Bolt was not detected. Please add the following line to your Gemfile:"
  log.error "gem 'bolt'"
  log.error "Note that this requires Puppet >= 6 and will cause dependency issues if you are using an older version of Puppet"
  throw e
end

class Onceover
  class Bolt
    # Inlcude bolt libraries for running tasks
    include BoltSpec::Run

    attr_accessor :modulepath
    attr_accessor :inventory_file

    def initialize(opts)
      @repo           = opts[:repo]
      @inventory_file = opts[:inventory_file]
      @modulepath     = @repo.temp_modulepath
    end

    def run_task(task_name, nodes, params)
      nodes      = [nodes].flatten # Convert to array
      nodes_list = nodes_to_list(nodes)
      targets    = find_targets(inventory, nodes_list)
      config     = { 'modulepath' => @modulepath }

      log.debug "Running task '#{task_name}' on #{targets} with params: #{params}"
      log_results(super(task_name, targets, params, config: config, inventory: inventory))
    end

    def apply_manifest(manifest, nodes, opts)
      nodes      = [nodes].flatten # Convert to array
      nodes_list = nodes_to_list(nodes)
      targets    = find_targets(inventory, nodes_list)
      require 'pry'
      binding.pry

      super(apply_manifest(manifest, targets, *opts))
    end

    def inventory
      if File.file?(@inventory_file)
        YAML.safe_load(File.read(@inventory_file))
      else
        bootstrap_inventory!
        inventory
      end
    end

    def bolt_inventory
      ::Bolt::Inventory.new(inventory)
    end

    # Extracts a flat list of nodes from an inventory
    def extract_all_nodes
      nodes = {}

      bolt_inventory.collect_groups.each do |name, group|
        nodes.merge!(group.nodes)
      end

      nodes
    end

    private

    # Finds targets to perform operations on from an inventory hash.
    #
    # @param inventory_hash [Hash] hash of the inventory.yaml file
    # @param targets [Array]
    # @return [Array] array of targets.
    def find_targets(inventory_hash, targets)
      if targets.nil?
        inventory = Bolt::Inventory.new(inventory_hash, nil)
        targets = inventory.node_names.to_a
      else
        targets = [targets]
      end
      targets
    end

    def nodes_to_list(nodes)
      nodes.map do |node|
        case node
        when String
          node # Handle strings nicely
        when Onceover::Node
          node.inventory_name
        end
      end
    end

    def bootstrap_inventory!
      log.debug "Bootstrapping inventory file at #{@inventory_file}"
      inventory_content = {
        'groups' => [
          {
            'name'  => 'ssh_nodes',
            'nodes' => [],
          },
          {
            'name'  => 'winrm_nodes',
            'nodes' => [],
          },
          {
            'name'  => 'docker_nodes',
            'nodes' => [],
          },
        ]
      }

      File.write(@inventory_file, inventory_content.to_yaml)
    end

    def log_results(results)
      results.each do |result|
        # Choose log level dynamically
        method = (result['status'] == 'success' ? :debug : :error)

        log.send(method, "#{result['object']} complete, results:")
        result.to_yaml.split("\n").each { |l| log.send(method,l) }

        raise "Task failed!" unless result['status'] == 'success'
      end
    end
  end
end