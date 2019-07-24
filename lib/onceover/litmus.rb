class Onceover
  # Manages litmus things
  class Litmus
    def initialize(opts = {})
      Onceover::Litmus.require!

      @root     = opts[:root]     || Dir.pwd
      @rakefile = opts[:rakefile] || "#{@root}/Rakefile"

      logger.debug "Telling rake to load the ganerated Rakefile at: #{@rakefile}"
      load_rakefile(@rakefile)
    end

    def up(node)
      logger.debug "Provisioning #{node.name} using litmus"

      cd do
        Rake::Task['litmus:provision'].invoke(node.provisioner, node.image)
        Rake::Task['litmus:provision'].reenable
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
      original_logger = logger

      begin
        logger.debug "Loading Litmus"
        require 'puppet_litmus'
        require 'rake'
        require 'puppet_litmus/rake_tasks'
        require 'puppetlabs_spec_helper/rake_tasks'
      rescue LoadError => e
        logger.error "Something went wrong loading Litmus, probably Litmus was not detected. Please add the following line to your gemfile:"
        logger.error "gem 'puppet_litmus"
        logger.error "Note that this requires Puppet >= 6 and will cause dependency issues if you are using an older version of Puppet"
        throw e
      ensure
        # include Onceover::Logger
        # logger.level = level
        logger = original_logger
      end

      require 'pry'
      binding.pry

    end

    private

    def load_rakefile(file)
      # Don't reload if it's already done
      return nil if Rake::Task.tasks.any? { |t| t.name == 'litmus:provision'}

      Rake.load_rakefile(file)
    end
  end
end
