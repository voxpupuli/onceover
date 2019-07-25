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
      require 'onceover/bolt'
      require 'onceover/provisioner'
      require 'onceover/runner/acceptance'
 
      nodes       = [] # Used to track all nodes
      bolt        = Onceover::Bolt.new(
        repo:           @repo,
        inventory_file: "#{@repo.tempdir}/inventory.yaml",
      )
      provisioner = Onceover::Provisioner.new(
        root: @repo.tempdir,
        bolt: bolt,
      )
      acceptance  = Onceover::Runner::Acceptance.new(bolt, provisioner)

      # Loop Over each role and create the nodes
      with_each_role(@config.acceptance_tests) do |_role, platform_tests|
        acceptance.provision!(platform_tests)

        acceptance.post_build_tasks!(platform_tests)

        acceptance.agent_install!(platform_tests)

        acceptance.post_install_tasks!(platform_tests)

        acceptance.code!(platform_tests)

        acceptance.run!(platform_tests)

        acceptance.tear_down!(platform_tests)
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
