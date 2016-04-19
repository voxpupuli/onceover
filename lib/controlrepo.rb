require 'r10k/puppetfile'
require 'erb'
require 'json'
require 'yaml'
require 'find'
require 'pathname'
require 'controlrepo/beaker'
require 'controlrepo/logger'
include Controlrepo::Logger

begin
  require 'pry'
rescue LoadError
  # We don't care if i'ts not here, this is just used for
  # debugging sometimes
end

class Controlrepo
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
  attr_accessor :controlrepo_yaml

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
   Controlrepo.new.root
  end

  def self.puppetfile
   Controlrepo.new.puppetfile
  end

  def self.facts_files
   Controlrepo.new.facts_files
  end

  def self.classes
   Controlrepo.new.classes
  end

  def self.roles
    Controlrepo.new.roles
  end

  def self.profiles
    Controlrepo.new.profiles
  end

  def self.config
    Controlrepo.new.config
  end

  def self.facts(filter = nil)
    Controlrepo.new.facts(filter)
  end

  def self.hiera_config_file
    Controlrepo.new.hiera_config_file
  end
  #
  # End class methods
  #

  def initialize(opts = {})
    # When we initialize the object it is going to set some instance vars

    @root             = opts[:path] || Dir.pwd
    @environmentpath  = opts[:environmentpath] || 'etc/puppetlabs/code/environments'
    @puppetfile       = opts[:puppetfile] || File.expand_path('./Puppetfile',@root)
    @environment_conf = opts[:environment_conf] || File.expand_path('./environment.conf',@root)
    @facts_dir        = opts[:facts_dir] || File.expand_path('./spec/factsets',@root)
    @spec_dir         = opts[:spec_dir] || File.expand_path('./spec',@root)
    @facts_files      = opts[:facts_files] || [Dir["#{@facts_dir}/*.json"],Dir["#{File.expand_path('../../factsets',__FILE__)}/*.json"]].flatten
    @nodeset_file     = opts[:nodeset_file] || File.expand_path('./spec/acceptance/nodesets/controlrepo-nodes.yml',@root)
    @role_regex       = /role[s]?:{2}/
    @profile_regex    = /profile[s]?:{2}/
    @tempdir          = opts[:tempdir] || ENV['CONTROLREPO_temp'] || File.absolute_path('./.controlrepo')
    $temp_modulepath  = nil
    @manifest         = opts[:manifest] || config['manifest'] ? File.expand_path(config['manifest'],@root) : nil
    @controlrepo_yaml  = opts[:controlrepo_yaml] || "#{@spec_dir}/controlrepo.yaml"
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
    #{'controlrepo.yaml'.green} #{@controlrepo_yaml}
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
    # Remove relative references
    code_dirs.delete_if { |dir| dir[0] == '$'}

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

  def fixtures
    # Load up the Puppetfile using R10k
    puppetfile = R10K::Puppetfile.new(@root)
    modules = puppetfile.load

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
    Controlrepo.evaluate_template('.fixtures.yml.erb',binding)
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

    Controlrepo.init_write_file(generate_controlrepo_yaml(repo),repo.controlrepo_yaml)
    Controlrepo.init_write_file(generate_nodesets(repo),repo.nodeset_file)
    Controlrepo.init_write_file(Controlrepo.evaluate_template('pre_conditions_README.md.erb',binding),File.expand_path('./pre_conditions/README.md',repo.spec_dir))
    Controlrepo.init_write_file(Controlrepo.evaluate_template('factsets_README.md.erb',binding),File.expand_path('./factsets/README.md',repo.spec_dir))

    # Add .controlrepo to Gitignore
    gitignore_path = File.expand_path('.gitignore',repo.root)
    if File.exists? gitignore_path
      gitignore_content = (File.open(gitignore_path,'r') {|f| f.read }).split("\n")
      message = "#{'changed'.green}"
    else
      message = "#{'created'.green}"
      gitignore_content = []
    end

    unless gitignore_content.include?(".controlrepo")
      gitignore_content << ".controlrepo\n"
      File.open(gitignore_path,'w') {|f| f.write(gitignore_content.join("\n")) }
      puts "#{message} #{Pathname.new(gitignore_path).relative_path_from(Pathname.new(Dir.pwd)).to_s}"
    end
  end

  def self.generate_controlrepo_yaml(repo)
    # This will return a controlrepo.yaml that can be written to a file
    Controlrepo.evaluate_template('controlrepo.yaml.erb',binding)
  end

  def self.generate_nodesets(repo)
    require 'controlrepo/beaker'
    require 'net/http'
    require 'json'

    hosts_hash = {}

    repo.facts.each do |fact_set|
      node_name = File.basename(repo.facts_files[repo.facts.index(fact_set)],'.json')
      boxname = Controlrepo::Beaker.facts_to_vagrant_box(fact_set)
      platform = Controlrepo::Beaker.facts_to_platform(fact_set)

      logger.debug "Querying hashicorp API for Vagrant box that matches #{boxname}"
      response = Net::HTTP.get(URI.parse("https://atlas.hashicorp.com/api/v1/box/#{boxname}"))
      url = 'URL goes here'

      if response =~ /Not Found/i
        comment_out = true
      else
        comment_out = false
        box_info = JSON.parse(response)
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
    Controlrepo.evaluate_template('nodeset.yaml.erb',binding)
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
    template_dir = File.expand_path('../templates',File.dirname(__FILE__))
    template = File.read(File.expand_path("./#{template_name}",template_dir))
    ERB.new(template, nil, '-').result(bind)
  end

  def self.init_write_file(contents,out_file)
    Controlrepo.create_dirs_and_log(File.dirname(out_file))
    if File.exists?(out_file)
      puts "#{'skipped'.yellow} #{Pathname.new(out_file).relative_path_from(Pathname.new(Dir.pwd)).to_s} #{'(exists)'.yellow}"
    else
      File.open(out_file,'w') {|f| f.write(contents)}
      puts "#{'created'.green} #{Pathname.new(out_file).relative_path_from(Pathname.new(Dir.pwd)).to_s}"
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
