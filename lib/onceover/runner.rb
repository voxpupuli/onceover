require 'backticks'

class Onceover
  class Runner
    attr_reader :repo
    attr_reader :config

    def initialize(repo, config, mode = [:spec, :acceptance])
      @repo   = repo
      @config = config
      @mode   = [mode].flatten
      @command_prefix = ENV['BUNDLE_GEMFILE'] ? 'bundle exec ' : ''
    end

    def prepare!
      # Remove the entire spec directory to make sure we have
      # all the latest tests
      FileUtils.rm_rf("#{@repo.tempdir}/spec")

      # Remove any previous failure log
      FileUtils.rm_f("#{@repo.tempdir}/failures.out")

      # Create the other directories we need
      FileUtils.mkdir_p("#{@repo.tempdir}/spec/classes")

      # Copy our entire spec directory over
      FileUtils.cp_r("#{@repo.spec_dir}", "#{@repo.tempdir}")

      # Create the Rakefile so that we can take advantage of the existing tasks
      @config.write_rakefile(@repo.tempdir, "spec/classes/**/*_spec.rb")

      # Create spec_helper.rb
      @config.write_spec_helper("#{@repo.tempdir}/spec", @repo)

      # TODO: Remove all tests that do not match set tags

      if @mode.include?(:spec)
        # Deduplicate and write the tests (Spec and Acceptance)
        @config.run_filters(Onceover::Test.deduplicate(@config.spec_tests)).each do |test|
          @config.verify_spec_test(@repo, test)
          @config.write_spec_test("#{@repo.tempdir}/spec/classes", test)
        end
      end

      # Parse the current hiera config, modify, and write it to the temp dir
      unless @repo.hiera_config == nil
        hiera_config = @repo.hiera_config
        hiera_config.each do |setting, value|
          if value.is_a?(Hash)
            if value.has_key?(:datadir)
              hiera_config[setting][:datadir] = "#{@repo.tempdir}/#{@repo.environmentpath}/production/#{value[:datadir]}"
            end
          end
        end
        File.write("#{@repo.tempdir}/#{@repo.environmentpath}/production/hiera.yaml", hiera_config.to_yaml)
      end

      @config.create_fixtures_symlinks(@repo)
    end

    def run_spec!
      Dir.chdir(@repo.tempdir) do
        # Disable warnings unless we are running in debug mode
        unless log.level.zero?
          previous_rubyopt = ENV['RUBYOPT']
          ENV['RUBYOPT']   = ENV['RUBYOPT'].to_s + ' -W0'
        end

        #`bundle install --binstubs`
        #`bin/rake spec_standalone`
        if @config.opts[:parallel]
          log.debug "Running #{@command_prefix}rake parallel_spec from #{@repo.tempdir}"
          result = Backticks::Runner.new(interactive:true).run(@command_prefix.strip.split, 'rake', 'parallel_spec').join
        else
          log.debug "Running #{@command_prefix}rake spec_standalone from #{@repo.tempdir}"
          result = Backticks::Runner.new(interactive:true).run(@command_prefix.strip.split, 'rake', 'spec_standalone').join
        end

        # Reset env to previous state if we modified it
        unless log.level.zero?
          ENV['RUBYOPT'] = previous_rubyopt
        end

        # Print a summary if we were running in parallel
        if @config.formatters.include? 'OnceoverFormatterParallel'
          require 'onceover/rspec/formatters'
          formatter = OnceoverFormatterParallel.new(STDOUT)
          formatter.output_results("#{repo.tempdir}/parallel")
        end

        # Finally exit and preserve the exit code
        exit result.status.exitstatus
      end
    end

    def run_acceptance!
      require 'tty-spinner'
      require 'onceover/bolt'
      require 'onceover/provisioner'
      require 'fileutils'
 
      all_node_spinners = []
      all_role_spinners = []
      results           = {}

      # Set up a queue of mutexes for locking Bolt to a given number of copies
      @bolt_locks       = Queue.new
      bolt_concurrency  = 2
      bolt_concurrency.times do
        @bolt_locks << Mutex.new
      end
      
      # Calculate all of the bolt options
      onceover_module_path = File.expand_path('../../..',  __dir__)
      bolt_opts = {
        'format'     => 'json',
        'modulepath' => "#{@repo.temp_modulepath}:#{onceover_module_path}",
        'boltdir'    => File.join(@repo.tempdir, @repo.environmentpath, 'production'),
      }

      # Verify all acceptance tests and fail early
      final_tests = @config.run_filters(Onceover::Test.deduplicate(@config.acceptance_tests))
      final_tests.each do |test|
        @config.verify_acceptance_test(@repo, test)
      end

      puts ""

      # Loop over each role and create the spinners
      with_each_role(final_tests) do |role, platform_tests|
        role_spinner = TTY::Spinner::Multi.new("[:spinner] #{role}")
        all_role_spinners << role_spinner
        all_role_spinners.flatten!

        node_spinners = platform_tests.map do |t|
          role_spinner.register("[:spinner] #{t.nodes.first.name} :stage") do |spinner|
            spinner.update(stage: 'Preparing'.yellow)
            prod_dir       = File.join(@repo.tempdir, @repo.environmentpath, 'production')
            inventory_path = File.join(@repo.tempdir, "bolt_#{t.to_s}")
            inventory_file = File.join(@repo.tempdir, @repo.environmentpath, 'production', 'inventory.yaml')

            plan_params = {
              'tests'          => [t.to_bolt],
              'cache_location' => prod_dir,
              'inventory_path' => inventory_path,
            }

            # Create Bolt cache
            FileUtils.mkdir_p(inventory_path)

            # Write the plan params for debugging
            File.write(File.join(@repo.tempdir, "bolt_#{t.to_s}", "plan_params.json"), plan_params.to_json)

            # Copy in the inventory file if it exists
            if File.file?(inventory_file)
              FileUtils.cp(inventory_file, inventory_path)
            end

            spinner.update(stage: 'Waiting'.yellow)
            # Wait until we can get a lock
            bolt_lock = @bolt_locks.shift

            # Lock it to be safe
            bolt_lock.lock

            spinner.update(stage: 'Running'.blue)
            result = JSON.parse(Onceover::BoltCLI.run_plan('onceover::acceptance', plan_params, bolt_opts))

            # Unlock and give back the lock
            bolt_lock.unlock
            @bolt_locks << bolt_lock

            results[t] = result

            if result['result'] == 'success'
              spinner.update(stage: 'Pass'.green)
              spinner.success
            else
              spinner.update(stage: 'Fail'.red)
              spinner.error
            end
          end
        end
        
        all_node_spinners << node_spinners
        all_node_spinners.flatten!
      end

      all_role_spinners.each(&:auto_spin)
  
      # I will need to make this better...
      # TODO: Aggregate all inventory files into one
      # TODO: Add more configurable behaviour around what to do if nodes fail
      # TODO: Make the plan *much* more configurable
      results.values.each do |val|
        puts JSON.pretty_generate(val) unless val['result'] == 'success'
      end
    end

    private

    # Accepts a block with two parameters: the role name and the tests for that role
    # Loops over a block
    def with_each_role(tests)
      # Get all the tests
      tests = @config.run_filters(Onceover::Test.deduplicate(tests))

      # Group by role
      tests = tests.group_by { |t| t.classes.first.name }
      
      tests.each do |role_name, role_tests|
        yield(role_name, role_tests)
      end
    end
  end
end
