require 'bolt_spec/run'

class Onceover
  class Bolt
    # Inlcude bolt libraries for running tasks
    include BoltSpec::Run

    attr_accessor :modulepath

    def initialize(controlrepo, litmus)
      @repo       = controlrepo
      @litmus     = litmus
      @modulepath = @repo.temp_modulepath
    end

    def run_task(task_name, nodes, params)
      nodes   = [nodes].flatten # Convert to array
      targets = find_targets(@litmus.inventory, nodes.map { |n| n.litmus_name })
      config  = { 'modulepath' => @modulepath }

      super(task_name, targets, params, config: config, inventory: @litmus.inventory)
    end
  end
end