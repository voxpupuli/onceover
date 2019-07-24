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

      log.debug "Running task '#{task_name}' on #{targets} with params: #{params}"
      log_results(super(task_name, targets, params, config: config, inventory: @litmus.inventory))
    end

    def log_results(results)
      results.each do |result|
        log.debug "#{result['object']} complete, results:"
        log.debug "#{result['node']}: #{result['status']}"
        unless result['status'] == 'success'
          log.error "Task failed!"
          result.each { |k,v| log.error "#{k}: #{v}" unless k == 'result' }
          log.error result['result']['_output']

          raise "Task failed!"
        end
      end
    end
  end
end