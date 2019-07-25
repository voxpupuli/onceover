class Onceover
  class Provisioner
    attr_reader :root
    attr_reader :bolt

    def initialize(opts = {})
      @root           = opts[:root] || Dir.pwd
      @bolt           = opts[:bolt] || Onceover::Bolt.new
    end

    def up!(node)
      # Get the task params
      task_name, nodes, params = generate_params(node)

      params.merge!({'action' => 'provision'})

      log.info "Building node #{node.name} using #{node.provisioner}"

      # Build the machine
      results               = @bolt.run_task(task_name, nodes, params)
      # Extract the name from the results
      node_name             = results.first['result']['node_name']
      # Store the inventory details in memory
      node.inventory_object = @bolt.extract_all_nodes[node_name]
    end

    def down!(node)
      # Get the task params
      task_name, nodes, params = generate_params(node)

      params.merge!({'action' => 'tear_down'})

      log.info "Destroying node #{node.name} using #{node.provisioner}"

      @bolt.run_task(task_name, nodes, params)
    end

    private

    def generate_params(node)
      params = {
        'inventory' => File.expand_path("..", @bolt.inventory_file),
        'node_name' => node.inventory_name,
        'platform'  => node.platform
      }

      # Mege in any custom params
      params.merge!(node.provision_params)
      
      # Return all of the required for the task including the name and target
      ["provision::#{node.provisioner}", 'localhost', params]
    end
  end
end