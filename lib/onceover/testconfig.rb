require 'onceover/class'
require 'onceover/node'
require 'onceover/group'
require 'onceover/test'
require 'onceover/logger'
require 'onceover/controlrepo'
require 'git'
include Onceover::Logger

class Onceover
  class TestConfig
    require 'yaml'

    attr_accessor :classes
    attr_accessor :nodes
    attr_accessor :node_groups
    attr_accessor :class_groups
    attr_accessor :spec_tests
    attr_accessor :acceptance_tests
    attr_accessor :environment
    attr_accessor :opts
    attr_accessor :filter_tags
    attr_accessor :filter_classes
    attr_accessor :filter_nodes
    attr_accessor :mock_functions
    attr_accessor :before_conditions
    attr_accessor :after_conditions
    attr_accessor :skip_r10k
    attr_accessor :force
    attr_accessor :strict_variables
    attr_accessor :formatters

    def initialize(file, opts = {})
      begin
        config = YAML.safe_load(File.read(file), [Symbol])
      rescue Errno::ENOENT
        raise "Could not find #{file}"
      rescue Psych::SyntaxError
        raise "Could not parse #{file}, check that it is valid YAML and that the encoding is correct"
      end

      @classes           = []
      @nodes             = []
      @node_groups       = []
      @class_groups      = []
      @spec_tests        = []
      @acceptance_tests  = []
      @opts              = opts
      @mock_functions    = config['functions']
      @before_conditions = config['before']
      @after_conditions  = config['after']
      @strict_variables  = opts[:strict_variables] ? 'yes' : 'no'
      
      # Set dynamic defaults for format
      if Array(opts[:format]) == [:defaults]
        @formatters = opts[:parallel] ? ['OnceoverFormatterParallel'] : ['OnceoverFormatter']
      else
        @formatters = Array(opts[:format])
      end

      # Initialise all of the classes and nodes
      config['classes'].each { |clarse| Onceover::Class.new(clarse) } unless config['classes'] == nil
      @classes = Onceover::Class.all

      config['nodes'].each { |node| Onceover::Node.new(node) } unless config['nodes'] == nil
      @nodes = Onceover::Node.all

      # Add the 'all_classes' and 'all_nodes' default groups
      @node_groups  << Onceover::Group.new('all_nodes', @nodes)
      @class_groups << Onceover::Group.new('all_classes', @classes)

      # Initialise all of the groups
      config['node_groups'].each { |name, members| @node_groups << Onceover::Group.new(name, members) } unless config['node_groups'] == nil
      config['class_groups'].each { |name, members| @class_groups << Onceover::Group.new(name, members) } unless config['class_groups'] == nil

      @filter_tags    = opts[:tags]      ? [opts[:tags].split(',')].flatten : nil
      @filter_classes = opts[:classes]   ? [opts[:classes].split(',')].flatten.map {|x| Onceover::Class.find(x)} : nil
      @filter_nodes   = opts[:nodes]     ? [opts[:nodes].split(',')].flatten.map {|x| Onceover::Node.find(x)} : nil
      @skip_r10k      = opts[:skip_r10k] ? true : false
      @force          = opts[:force] || false

      # Validate the mock_functions
      if @mock_functions && @mock_functions.any? { |name, details| details.has_key? 'type' }
        logger.warn "The 'type' key for mocked functions is deprecated and will be ignored, please remove it."
      end

      # Loop over all of the items in the test matrix and add those as test
      # objects to the list of tests
      config['test_matrix'].each do |test_hash|
        test_hash.each do |machines, settings|
          if settings['tests'] == 'spec'
            @spec_tests << Onceover::Test.new(machines, settings['classes'], settings)
          elsif settings['tests'] == 'acceptance'
            @acceptance_tests << Onceover::Test.new(machines, settings['classes'], settings)
          elsif settings['tests'] == 'all_tests'
            tst = Onceover::Test.new(machines,settings['classes'],settings)
            @spec_tests << tst
            @acceptance_tests << tst
          end
        end
      end
    end

    def to_s
      require 'colored'

      <<-END.gsub(/^\s{4}/,'')
      #{'classes'.green}      #{@classes.map{|c|c.name}}
      #{'nodes'.green}        #{@nodes.map{|n|n.name}}
      #{'class_groups'.green} #{@class_groups}
      #{'node_groups'.green}  #{@node_groups.map{|g|g.name}}
      END
    end

    def self.find_list(thing)
      # Takes a string and finds an object or list of objects to match, will
      # take nodes, classes or groups

      # We want to supress warnings for this bit
      old_level = logger.level
      logger.level = :error
      if Onceover::Group.find(thing)
        logger.level = old_level
        return Onceover::Group.find(thing).members
      elsif Onceover::Class.find(thing)
        logger.level = old_level
        return [Onceover::Class.find(thing)]
      elsif Onceover::Node.find(thing)
        logger.level = old_level
        return [Onceover::Node.find(thing)]
      else
        logger.level = old_level
        raise "Could not find #{thing} in list of classes, nodes or groups"
      end
    end

    def self.subtractive_to_list(subtractive_hash)
      # Take a hash that looks like this:
      # { 'include' => 'somegroup'
      #   'exclude' => 'other'}
      # and return a list of classes/nodes
      if subtractive_hash.has_key?('include') && subtractive_hash.has_key?('exclude')
        include_list = Onceover::TestConfig.find_list(subtractive_hash['include']).flatten
        exclude_list = Onceover::TestConfig.find_list(subtractive_hash['exclude']).flatten
        include_list - exclude_list
      else
        raise "The classes/nodes hash must have an `exclude` if using an `include`"
      end
    end

    def verify_spec_test(controlrepo, test)
      test.nodes.each do |node|
        unless controlrepo.facts_files.any? { |file| file =~ /\/#{node.name}\.json/ }
          raise "Could not find factset for node: #{node.name}"
        end
      end
    end

    def verify_acceptance_test(controlrepo, test)
      warn "[DEPRECATION] #{__method__} is deprecated due to the removal of Beaker"

      require 'yaml'
      nodeset = YAML.load_file(controlrepo.nodeset_file)
      test.nodes.each do |node|
        unless nodeset['HOSTS'].has_key?(node.name)
          raise "Could not find nodeset for node: #{node.name}"
        end
      end
    end

    def pre_condition
      # Read all the pre_conditions and return the string
      spec_dir = Onceover::Controlrepo.new(@opts).spec_dir
      puppetcode = []
      Dir["#{spec_dir}/pre_conditions/*.pp"].each do |condition_file|
        logger.debug "Reading pre_conditions from #{condition_file}"
        puppetcode << File.read(condition_file)
      end
      return nil if puppetcode.count.zero?
      puppetcode.join("\n")
    end

    def write_spec_test(location, test)
      # Use an ERB template to write a spec test
      File.write("#{location}/#{test.to_s}_spec.rb",
        Onceover::Controlrepo.evaluate_template('test_spec.rb.erb', binding))
    end

    def write_acceptance_tests(location, tests)
      warn "[DEPRECATION] #{__method__} is deprecated due to the removal of Beaker"

      File.write("#{location}/acceptance_spec.rb",
        Onceover::Controlrepo.evaluate_template('acceptance_test_spec.rb.erb', binding))
    end

    def write_spec_helper_acceptance(location, repo)
      File.write("#{location}/spec_helper_acceptance.rb",
        Onceover::Controlrepo.evaluate_template('spec_helper_acceptance.rb.erb', binding))
    end

    def write_rakefile(location, pattern)
      File.write("#{location}/Rakefile",
        Onceover::Controlrepo.evaluate_template('testconfig_Rakefile.erb', binding))
    end

    def write_spec_helper(location, repo)
      environmentpath = "#{repo.tempdir}/#{repo.environmentpath}"
      modulepath = repo.config['modulepath']
      modulepath.delete("$basemodulepath")
      modulepath.map! do |path|
        "#{environmentpath}/production/#{path}"
      end

      # We need to select the right delimiter based on OS
      require 'facter'
      if Facter[:kernel].value == 'windows'
        modulepath = modulepath.join(";")
      else
        modulepath = modulepath.join(':')
      end

      repo.temp_modulepath = modulepath

      # Use an ERB template to write a spec test
      File.write("#{location}/spec_helper.rb",
        Onceover::Controlrepo.evaluate_template('spec_helper.rb.erb', binding))
    end

    def create_fixtures_symlinks(repo)
      logger.debug "Creating fixtures symlinks"
      FileUtils.rm_rf("#{repo.tempdir}/spec/fixtures/modules")
      FileUtils.mkdir_p("#{repo.tempdir}/spec/fixtures/modules")
      repo.temp_modulepath.split(':').each do |path|
        Dir["#{path}/*"].each do |mod|
          modulename = File.basename(mod)
          link = "#{repo.tempdir}/spec/fixtures/modules/#{modulename}"
          logger.debug "Symlinking #{mod} to #{link}"
          unless File.symlink?(link)
            # Ruby only sets File::ALT_SEPARATOR on Windows and Rubys standard library
            # uses this to check for Windows
            if !!File::ALT_SEPARATOR
              mod = File.join(File.dirname(link), mod) unless Pathname.new(mod).absolute?
              if Dir.respond_to?(:create_junction)
                Dir.create_junction(link, mod)
              else
                system("call mklink /J \"#{link.gsub('/', '\\')}\" \"#{mod.gsub('/', '\\')}\"")
              end
            else
              FileUtils.ln_s(mod, link)
            end
          end
        end
      end
    end

    def run_filters(tests)
      # All of this needs to be applied AFTER deduplication but BEFORE writing
      filters = {
        'tags'    => @filter_tags,
        'classes' => @filter_classes,
        'nodes'   => @filter_nodes
      }
      filters.each do |method, filter_list|
        if filter_list
          # Remove tests that do not have matching tags
          tests.keep_if do |test|
            filter_list.any? do |filter|
              if test.send(method)
                test.send(method).include?(filter)
              else
                false
              end
            end
          end
        end
      end
      tests
    end
  end
end
