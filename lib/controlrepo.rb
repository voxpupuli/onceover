require 'r10k/puppetfile'
require 'erb'
require 'json'
require 'yaml'
require 'find'
require 'pathname'
require 'controlrepo/beaker'
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
  attr_accessor :role_regex
  attr_accessor :profile_regex
  attr_accessor :temp_environmentpath
  attr_accessor :tempdir
  attr_accessor :spec_dir
  attr_accessor :temp_modulepath
  attr_accessor :nodeset_file

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

  def initialize(search_path = Dir.pwd)
    # When we initialize the object it is going to set some instance vars
    begin
      # Find the root of the control repo by traversing up
      until File.exist?(File.expand_path('./Puppetfile',search_path)) do
        search_path = File.expand_path('..',search_path)
      end
    rescue => e
      raise " Could not find Puppetfile"
      raise e
    end
    @root = search_path
    @puppetfile = File.expand_path('./Puppetfile',@root)
    @environment_conf = File.expand_path('./environment.conf',@root)
    @facts_dir = File.expand_path('./spec/factsets',@root)
    @spec_dir = File.expand_path('./spec',@root)
    @facts_files = [Dir["#{@facts_dir}/*.json"],Dir["#{File.expand_path('../../factsets',__FILE__)}/*.json"]].flatten
    @nodeset_file = File.expand_path('./spec/acceptance/nodesets/controlrepo-nodes.yml',@root)
    @role_regex = /role[s]?:{2}/
    @profile_regex = /profile[s]?:{2}/
    @temp_environmentpath = nil
    @tempdir = nil
    $temp_modulepath = nil
  end

  def to_s
    <<-END.gsub(/^\s{4}/,'')
    puppetfile: #{@puppetfile}
    environment_conf: #{@environment_conf}
    facts_dir: #{@facts_dir}
    spec_dir: #{@spec_dir}
    facts_files: #{@facts_files}
    nodeset_file: #{@nodeset_file}
    roles: #{roles}
    profiles #{profiles}
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
    template_dir = File.expand_path('../templates',File.dirname(__FILE__))
    fixtures_template = File.read(File.expand_path('./.fixtures.yml.erb',template_dir))
    fixtures_yaml = ERB.new(fixtures_template, nil, '-').result(binding)
    return fixtures_yaml
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