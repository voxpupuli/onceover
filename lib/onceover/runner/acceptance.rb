# This class manages most of the acceptance testing steps.
# All methods here should take a number of tests as a parameter, all will assume
# that these tests have been deduplicated and therefore.
#
# The main steps for running acceptance tests are:
#
#   - Provision          (serial)
#   - Post-build tasks   (serial)
#   - Agent install      (parallel)
#   - Post-install tasks (serial)
#   - Code setup         (parallel)
#   - Puppet run         (parallel)
#   - 2nd Puppet run     (parallel)
#   - Tear down          (serial)
class Onceover
  class Runner
    class Acceptance
      def initialize(bolt, provisioner)
        @bolt        = bolt
        @provisioner = provisioner
        @mutex       = Mutex.new
      end

      def provision!(tests)
        each_test(tests) do |role, node|
          @provisioner.up!(node)
        end
      end

      def post_build_tasks!(tests)
        log.debug "Running post-build tasks..."
        each_test(tests) do |role, node|
          node.post_build_tasks.each do |task|
            log.info "Running task '#{task['name']}' on #{node.inventory_name}"
            @bolt.run_task(task['name'], node, task['parameters'])
          end
        end
      end

      def agent_install!(tests)
        # Install the Puppet agent on all nodes
        log.info "Installing the Puppet agent on all nodes"
        @bolt.run_task('puppet_agent::install', all_nodes(tests), { 'version' => Puppet.version })
      end

      def post_install_tasks!(tests)
        # Run all the post-install tasks
        log.debug "Running post-install tasks..."
        each_test(tests) do |role, node|
          node.post_install_tasks.each do |task|
            log.info "Running task '#{task['name']}' on #{node.inventory_name}"
            @bolt.run_task(task['name'], node, task['parameters'])
          end
        end
      end

      def code!(tests)

      end

      def run!(tests)

      end

      def tear_down!(tests)
        log.debug "Running destroying all nodes..."
        each_test(tests) do |role, node|
          @provisioner.down!(node)
        end
      end

      private

      def each_test(tests)
        tests = [tests].flatten # Convert to array

        tests.each do |test|
          role = test.classes.first
          node = test.nodes.first

          yield(role, node)
        end
      end

      def all_nodes(tests)
        tests = [tests].flatten # Convert to array

        tests.map { |t| t.nodes.first }
      end
    end
  end
end