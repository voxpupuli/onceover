require 'r10k/puppetfile'
require 'erb'
require 'json'
require 'yaml'
require 'find'
require 'pathname'
require 'thread'
require 'onceover/beaker'
require 'onceover/logger'
include Onceover::Logger

class Onceover
  class Controlrepo
    # This exists for caching. Each time a new one of these objects is created
    # it gets dumped in here so that it's values can be called without
    # reference to the initial object itself
    @@existing_controlrepo = nil

    attr_accessor :root
    attr_accessor :puppetfile
    attr_accessor :facts_files
    attr_accessor :environmentpath
    attr_accessor :role_regex
    attr_accessor :profile_regex
    attr_accessor :spec_dir
    attr_accessor :temp_modulepath
    attr_accessor :nodeset_file
    attr_accessor :manifest
    attr_accessor :tempdir
    attr_accessor :onceover_yaml
    attr_accessor :opts

    # Create methods on self so that we can access these basic things without
    # having to actually instantiate the class, I'm debating how much stuff
    # I should be putting in here, we don't reeeally need to instantiate the
    # object unless we want to modify it's parameters, so maybe everything.
    # We shall see...
    #
    # And yeah I know this makes little sense, but it will look nicer to type, promise
    #
    # Also it's probably pretty memory hungry, but let's be honest, how many
    # times would be be calling this? If we call it over and over you can just
    # instantiate it anyway
    def self.root
     @@existing_controlrepo.root
    end

    def self.puppetfile
     @@existing_controlrepo.puppetfile
    end

    def self.facts_files
     @@existing_controlrepo.facts_files
    end

    def self.classes
     @@existing_controlrepo.classes
    end

    def self.roles
      @@existing_controlrepo.roles
    end

    def self.profiles
      @@existing_controlrepo.profiles
    end

    def self.config
      @@existing_controlrepo.config
    end

    def self.facts(filter = nil)
      @@existing_controlrepo.facts(filter)
    end

    def self.hiera_config_file
      @@existing_controlrepo.hiera_config_file
    end
    #
    # End class methods
    #

    def initialize(opts = {})
      # When we initialize the object it is going to set some instance vars

      # We want people to be able to run this from anywhere within the repo
      # so traverse up until we think we are in a controlrepo.
      if opts[:path]
        @root = opts[:path]
      else
        @root = Dir.pwd
        until File.exist?(File.expand_path('./environment.conf',@root)) do
          # Throw an exception if we can't go any further up
          throw "Could not file root of the controlrepo anywhere above #{Dir.pwd}" if @root == File.expand_path('../',@root)

          # Step up and try again
          @root = File.expand_path('../',@root)
        end
      end

      @environmentpath  = opts[:environmentpath] || 'etc/puppetlabs/code/environments'
      @puppetfile       = opts[:puppetfile] || File.expand_path('./Puppetfile',@root)
      @environment_conf = opts[:environment_conf] || File.expand_path('./environment.conf',@root)
      @facts_dir        = opts[:facts_dir] || File.expand_path('./spec/factsets',@root)
      @spec_dir         = opts[:spec_dir] || File.expand_path('./spec',@root)
      @facts_files      = opts[:facts_files] || [Dir["#{@facts_dir}/*.json"],Dir["#{File.expand_path('../../../factsets',__FILE__)}/*.json"]].flatten
      @nodeset_file     = opts[:nodeset_file] || File.expand_path('./spec/acceptance/nodesets/onceover-nodes.yml',@root)
      @role_regex       = /role[s]?:{2}/
      @profile_regex    = /profile[s]?:{2}/
      @tempdir          = opts[:tempdir] || File.expand_path('./.onceover',@root)
      $temp_modulepath  = nil
      @manifest         = opts[:manifest] || config['manifest'] ? File.expand_path(config['manifest'],@root) : nil
      @onceover_yaml    = opts[:onceover_yaml] || "#{@spec_dir}/onceover.yaml"
      @opts             = opts
      logger.level = :debug if @opts[:debug]
      @@existing_controlrepo = self
    end

    def to_s
      require 'colored'

      <<-END.gsub(/^\s{4}/,'')
      #{'puppetfile'.green}       #{@puppetfile}
      #{'environment_conf'.green} #{@environment_conf}
      #{'facts_dir'.green}        #{@facts_dir}
      #{'spec_dir'.green}         #{@spec_dir}
      #{'facts_files'.green}      #{@facts_files}
      #{'nodeset_file'.green}     #{@nodeset_file}
      #{'roles'.green}            #{roles}
      #{'profiles'.green}         #{profiles}
      #{'onceover.yaml'.green}    #{@onceover_yaml}
      END
    end

    def roles
      classes.keep_if { |c| c =~ @role_regex }
    end

    def profiles
      classes.keep_if { |c| c =~ @profile_regex }
    end

    def classes
      # Get all of the possible places for puppet code and look for classes
      code_dirs = self.config['modulepath']
      # Remove interpolated references
      code_dirs.delete_if { |dir| dir[0] == '$'}

      # Make sure that the paths are relative to the controlrepo root
      code_dirs.map! do |dir|
        File.expand_path(dir,@root)
      end

      # Get all the classes from all of the manifests
      classes = []
      code_dirs.each do |dir|
        classes << get_classes(dir)
      end
      classes.flatten
    end

    def facts(filter = nil)
      # Returns an array facts hashes
      all_facts = []
      logger.debug "Reading factsets"
      @facts_files.each do |file|
        all_facts << read_facts(file)['values']
      end
      if filter
        # Allow us to pass a hash of facts to filter by
        raise "Filter param must be a hash" unless filter.is_a?(Hash)
        all_facts.keep_if do |hash|
          matches = []
          filter.each do |filter_fact,value|
            matches << keypair_is_in_hash(hash,filter_fact,value)
          end
          if matches.include? false
            false
          else
            true
          end
        end
      end
      return all_facts
    end

    def print_puppetfile_table
      require 'table_print'
      require 'versionomy'
      require 'colored'
      require 'r10k/puppetfile'

      # Load up the Puppetfile using R10k
      logger.debug "Reading puppetfile from #{@root}"
      puppetfile = R10K::Puppetfile.new(@root)
      logger.debug "Loading modules from Puppetfile"
      puppetfile.load!

      output_array = []
      threads      = []
      puppetfile.modules.each do |mod|
        threads << Thread.new do
          return_hash = {}
          logger.debug "Loading data for #{mod.full_name}"
          return_hash[:full_name] = mod.full_name
          if mod.is_a?(R10K::Module::Forge)
            return_hash[:current_version] = mod.expected_version
            return_hash[:latest_version] = mod.v3_module.current_release.version
            current = Versionomy.parse(return_hash[:current_version])
            latest = Versionomy.parse(return_hash[:latest_version])
            if current.major < latest.major
              return_hash[:out_of_date] = "Major".red
            elsif current.minor < latest.minor
              return_hash[:out_of_date] = "Minor".yellow
            elsif current.tiny < latest.tiny
              return_hash[:out_of_date] = "Tiny".green
            else
              return_hash[:out_of_date] = "No".green
            end
          else
            return_hash[:current_version] = "N/A"
            return_hash[:latest_version] = "N/A"
            return_hash[:out_of_date] = "N/A"
          end
          output_array << return_hash
        end
      end

      threads.map(&:join)

      tp output_array, \
        {:full_name => {:display_name => "Full Name"}}, \
        {:current_version => {:display_name => "Current Version"}}, \
        {:latest_version => {:display_name => "Latest Version"}}, \
        {:out_of_date => {:display_name => "Out of Date?"}}
    end

    def update_puppetfile
      require 'r10k/puppetfile'

      # Read in the Puppetfile as a string and as an object
      puppetfile_string = File.read(@puppetfile).split("\n")
      puppetfile = R10K::Puppetfile.new(@root)
      puppetfile.load!

      # TODO: Make sure we can deal with :latest

      # Create threading resources
      threads = []
      queue   = Queue.new
      queue.push(puppetfile_string)

      puppetfile.modules.keep_if {|m| m.is_a?(R10K::Module::Forge)}
      puppetfile.modules.each do |mod|
        threads << Thread.new do
          logger.debug "Getting latest version of #{mod.full_name}"
          latest_version = mod.v3_module.current_release.version

          # Get the data off the queue, or wait if something else is using it
          puppetfile_string_temp = queue.pop
          line_index = puppetfile_string_temp.index {|l| l =~ /^\s*[^#]*#{mod.owner}[\/-]#{mod.name}/}
          puppetfile_string_temp[line_index].gsub!(mod.expected_version,latest_version)

          # Put the data back into the queue once we are done with it
          queue.push(puppetfile_string_temp)
        end
      end

      threads.map(&:join)
      puppetfile_string = queue.pop

      File.open(@puppetfile, 'w') {|f| f.write(puppetfile_string.join("\n")) }
      puts "#{'changed'.yellow} #{@puppetfile}"
    end

    def fixtures
      # Load up the Puppetfile using R10k
      puppetfile = R10K::Puppetfile.new(@root)
      fail 'Could not load Puppetfile' unless puppetfile.load
      modules = puppetfile.modules

      # Iterate over everything and seperate it out for the sake of readability
      symlinks = []
      forge_modules = []
      repositories = []

      modules.each do |mod|
        logger.debug "Converting #{mod.to_s} to .fixtures.yml format"
        # This logic could probably be cleaned up. A lot.
        if mod.is_a? R10K::Module::Forge
          if mod.expected_version.is_a?(Hash)
            # Set it up as a symlink, because we are using local files in the Puppetfile
            symlinks << {
              'name' => mod.name,
              'dir' => mod.expected_version[:path]
            }
          elsif mod.expected_version.is_a?(String)
            # Set it up as a normal firge module
            forge_modules << {
              'name' => mod.name,
              'repo' => mod.title,
              'ref' => mod.expected_version
            }
          end
        elsif mod.is_a? R10K::Module::Git
          # Set it up as a git repo
          repositories << {
              'name' => mod.name,
              # I know I shouldn't be doing this, but trust me, there are no methods
              # anywhere that expose this value, I looked.
              'repo' => mod.instance_variable_get(:@remote),
              'ref' => mod.version
            }
        end
      end

      # also add synlinks for anything that is in environment.conf
      code_dirs = self.config['modulepath']
      code_dirs.delete_if { |dir| dir[0] == '$'}
      code_dirs.each do |dir|
        # We need to traverse down into these directories and create a symlink for each
        # module we find because fixtures.yml is expecting the module's root not the
        # root of modulepath
        Dir["#{dir}/*"].each do |mod|
          symlinks << {
            'name' => File.basename(mod),
            'dir' => Pathname.new(File.expand_path(mod)).relative_path_from(Pathname.new(@root))#File.expand_path(mod)
          }
        end
      end

      # Use an ERB template to write the files
      Onceover::Controlrepo.evaluate_template('.fixtures.yml.erb',binding)
    end

    def hiera_config_file
      # try to find the hiera.iyaml file
      hiera_config_file = File.expand_path('./hiera.yaml',@spec_dir) if File.exist?(File.expand_path('./hiera.yaml',@spec_dir))
      hiera_config_file = File.expand_path('./hiera.yaml',@root) if File.exist?(File.expand_path('./hiera.yaml',@root))
      hiera_config_file
    end

    def hiera_config
      begin
        YAML.load_file(hiera_config_file)
      rescue TypeError
        puts "WARNING: Could not find hiera config file, continuing"
        nil
      end
    end

    def hiera_config=(data)
      File.write(hiera_config_file,data.to_yaml)
    end

    def hiera_data
      # This is going to try to find your hiera data directory, if you have named it something
      # unexpected it won't work
      possibe_datadirs = Dir["#{@root}/*/"]
      possibe_datadirs.keep_if { |dir| dir =~ /hiera(?:.*data)?/i }
      raise "There were too many directories that looked like hiera data: #{possibe_datadirs}" if possibe_datadirs.count > 1
      File.expand_path(possibe_datadirs[0])
    end

    def config
      # Parse the file
      logger.debug "Reading #{@environment_conf}"
      env_conf = File.read(@environment_conf)
      env_conf = env_conf.split("\n")

      # Delete commented out lines
      env_conf.delete_if { |l| l =~ /^\s*#/}

      # Map the lines into a hash
      environment_config = {}
      env_conf.each do |line|
        environment_config.merge!(Hash[*line.split('=').map { |s| s.strip}])
      end

      # Finally, split the modulepath values and return
      begin
        environment_config['modulepath'] = environment_config['modulepath'].split(':')
      rescue
        raise "modulepath was not found in environment.conf, don't know where to look for roles & profiles"
      end
      return environment_config
    end

    def r10k_config_file
      r10k_config_file = File.expand_path('./r10k.yaml',@spec_dir) if File.exist?(File.expand_path('./r10k.yaml',@spec_dir))
      r10k_config_file = File.expand_path('./r10k.yaml',@root) if File.exist?(File.expand_path('./r10k.yaml',@root))
      r10k_config_file
    end

    def r10k_config
      YAML.load_file(r10k_config_file)
    end

    def r10k_config=(data)
      File.write(r10k_config_file,data.to_yaml)
    end

    def temp_manifest
      config['manifest'] ? File.expand_path(config['manifest'],@tempdir) : nil
    end

    def self.init(repo)
      # This code will initialise a controlrepo with all of the config
      # that it needs
      require 'pathname'
      require 'colored'

      Onceover::Controlrepo.init_write_file(generate_onceover_yaml(repo),repo.onceover_yaml)
      # [DEPRECATION] Writing nodesets is deprecated due to the removal of Beaker"
      #Onceover::Controlrepo.init_write_file(generate_nodesets(repo),repo.nodeset_file)
      Onceover::Controlrepo.init_write_file(Onceover::Controlrepo.evaluate_template('pre_conditions_README.md.erb',binding),File.expand_path('./pre_conditions/README.md',repo.spec_dir))
      Onceover::Controlrepo.init_write_file(Onceover::Controlrepo.evaluate_template('factsets_README.md.erb',binding),File.expand_path('./factsets/README.md',repo.spec_dir))
      Onceover::Controlrepo.init_write_file(Onceover::Controlrepo.evaluate_template('Rakefile.erb',binding),File.expand_path('./Rakefile',repo.root))
      Onceover::Controlrepo.init_write_file(Onceover::Controlrepo.evaluate_template('Gemfile.erb',binding),File.expand_path('./Gemfile',repo.root))

      # Add .onceover to Gitignore
      gitignore_path = File.expand_path('.gitignore',repo.root)
      if File.exists? gitignore_path
        gitignore_content = (File.open(gitignore_path,'r') {|f| f.read }).split("\n")
        message = "#{'changed'.green}"
      else
        message = "#{'created'.green}"
        gitignore_content = []
      end

      unless gitignore_content.include?(".onceover")
        gitignore_content << ".onceover\n"
        File.open(gitignore_path,'w') {|f| f.write(gitignore_content.join("\n")) }
        puts "#{message} #{Pathname.new(gitignore_path).relative_path_from(Pathname.new(Dir.pwd)).to_s}"
      end
    end

    def self.generate_onceover_yaml(repo)
      # This will return a controlrepo.yaml that can be written to a file
      Onceover::Controlrepo.evaluate_template('controlrepo.yaml.erb',binding)
    end

    def self.generate_nodesets(repo)
      warn "[DEPRECATION] #{__method__} is deprecated due to the removal of Beaker"

      require 'onceover/beaker'
      require 'net/http'
      require 'json'

      hosts_hash = {}

      repo.facts.each do |fact_set|
        node_name = File.basename(repo.facts_files[repo.facts.index(fact_set)],'.json')
        boxname = Onceover::Beaker.facts_to_vagrant_box(fact_set)
        platform = Onceover::Beaker.facts_to_platform(fact_set)

        logger.debug "Querying hashicorp API for Vagrant box that matches #{boxname}"

        uri = URI("https://atlas.hashicorp.com:443/api/v1/box/#{boxname}")
        request = Net::HTTP.new(uri.host, uri.port)
        request.use_ssl = true
        response = request.get(uri)

        url = 'URL goes here'

        if response.code == "404"
          comment_out = true
        else
          comment_out = false
          box_info = JSON.parse(response.body)
          box_info['current_version']['providers'].each do |provider|
            if  provider['name'] == 'virtualbox'
              url = provider['original_url']
            end
          end
        end

        # Add the resulting info to the hosts hash. This is what the
        # template will output
        hosts_hash[node_name] = {
          :platform    => platform,
          :boxname     => boxname,
          :url         => url,
          :comment_out => comment_out
        }
      end

      # Use an ERB template
      Onceover::Controlrepo.evaluate_template('nodeset.yaml.erb',binding)
    end

    def self.create_dirs_and_log(dir)
      Pathname.new(dir).descend do |folder|
        unless folder.directory?
          FileUtils.mkdir(folder)
          puts "#{'created'.green} #{folder.relative_path_from(Pathname.new(Dir.pwd)).to_s}"
        end
      end
    end

    def self.evaluate_template(template_name,bind)
      logger.debug "Evaluating template #{template_name}"
      template_dir = File.expand_path('../../templates',File.dirname(__FILE__))
      template = File.read(File.expand_path("./#{template_name}",template_dir))
      ERB.new(template, nil, '-').result(bind)
    end

    def self.init_write_file(contents,out_file)
      Onceover::Controlrepo.create_dirs_and_log(File.dirname(out_file))
      if File.exists?(out_file)
        puts "#{'skipped'.yellow} #{Pathname.new(out_file).relative_path_from(Pathname.new(Dir.pwd)).to_s} #{'(exists)'.yellow}"
      else
        File.open(out_file,'w') {|f| f.write(contents)}
        puts "#{'created'.green} #{Pathname.new(out_file).relative_path_from(Pathname.new(Dir.pwd)).to_s}"
      end
    end

    # Returns the deduplicted and verified output of testconfig.spec_tests for
    # use in Rspec tests so that we don't have to deal with more than one object
    def spec_tests(&block)
      require 'onceover/testconfig'

      # Load up all of the tests and deduplicate them
      testconfig = Onceover::TestConfig.new(@onceover_yaml,@opts)
      testconfig.spec_tests.each { |tst| testconfig.verify_spec_test(self,tst) }
      tests = testconfig.run_filters(Onceover::Test.deduplicate(testconfig.spec_tests))

      # Loop over each test, executing the user's block on each
      tests.each do |tst|
        block.call(tst.classes[0].name,tst.nodes[0].name,tst.nodes[0].fact_set,testconfig.pre_condition)
      end
    end

    private

    def read_facts(facts_file)
      file = File.read(facts_file)
      begin
        result = JSON.parse(file)
      rescue JSON::ParserError
        raise "Could not parse the JSON file, check that it is valid JSON and that the encoding is correct"
      end
      result
    end

    def keypair_is_in_hash(first_hash, key, value)
      matches = []
      if first_hash.has_key?(key)
        if value.is_a?(Hash)
          value.each do |k,v|
            matches << keypair_is_in_hash(first_hash[key],k,v)
          end
        else
          if first_hash[key] == value
            matches << true
          else
            matches << false
          end
        end
      else
        matches << false
      end
      if matches.include? false
        false
      else
        true
      end
    end

    def get_classes(dir)
      classes = []
      # Recurse over all the pp files under the dir we are given
      logger.debug "Searching puppet code for roles and profiles"
      Dir["#{dir}/**/*.pp"].each do |manifest|
        classname = find_classname(manifest)
        # Add it to the array as long as it is not nil
        classes << classname if classname
      end
      classes
    end

    def find_classname(filename)
      file = File.new(filename, "r")
      while (line = file.gets)
        if line =~ /^class (\w+(?:::\w+)*)/
          return $1
        end
      end
      return nil
    end
  end
end
