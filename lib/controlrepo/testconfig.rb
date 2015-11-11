require 'controlrepo/class'
require 'controlrepo/node'
require 'controlrepo/group'
require 'controlrepo/test'

class Controlrepo
  class TestConfig
    require 'yaml'

    attr_accessor :classes
    attr_accessor :nodes
    attr_accessor :node_groups
    attr_accessor :class_groups
    attr_accessor :spec_tests
    attr_accessor :acceptance_tests
    attr_accessor :environment


# TODO: Add checking for missing fact and nodesets




    def initialize(file, environment = 'production')
      begin
        config = YAML.load(File.read(file))
      rescue YAML::ParserError
        raise "Could not parse the YAML file, check that it is valid YAML and that the encoding is correct"
      end

      @environment = environment
      @classes = []
      @nodes = []
      @node_groups = []
      @class_groups = []
      @spec_tests = []
      @acceptance_tests = []

      # Add the 'all_classes' and 'all_nodes' default groups
      @node_groups << Controlrepo::Group.new('all_nodes',@nodes)
      @class_groups << Controlrepo::Group.new('all_classes',@classes)

      config['classes'].each { |clarse| @classes << Controlrepo::Class.new(clarse) }
      config['nodes'].each { |node| @nodes << Controlrepo::Node.new(node) }
      config['node_groups'].each { |name, members| @node_groups << Controlrepo::Group.new(name, members) }
      config['class_groups'].each { |name, members| @class_groups << Controlrepo::Group.new(name, members) }

      config['test_matrix'].each do |machines, settings|
        if settings['tests'] == 'spec'
          @spec_tests << Controlrepo::Test.new(machines,settings['classes'],settings['options'])
        elsif settings['tests'] == 'acceptance'
          @acceptance_tests << Controlrepo::Test.new(machines,settings['classes'],settings['options'])
        elsif settings['tests'] == 'all_tests'
          test = Controlrepo::Test.new(machines,settings['classes'],settings['options'])
          @spec_tests << test
          @acceptance_tests << test
        end
        # TODO: Work out some way to set per-test options like idempotency
        #@spec_tests << Controlrepo::Test.new(machines,roles)
        #@acceptance_tests
      end
    end

    def self.find_list(thing)
      # Takes a string and finds an object or list of objects to match, will
      # take nodes, classes or groups
      if Controlrepo::Group.find(thing)
        return Controlrepo::Group.find(thing).members
      elsif Controlrepo::Class.find(thing)
        return [Controlrepo::Class.find(thing)]
      elsif Controlrepo::Node.find(thing)
        return [Controlrepo::Node.find(thing)]
      else
        raise "Could not find #{thing} in list of classes, nodes or groups"
      end
    end

    def verify_spec_test(controlrepo,test)
      test.nodes.each do |node|
        unless controlrepo.facts_files.any? { |file| file =~ /\/#{node}\.json/ }
          raise "Could not find factset for test: #{test.to_s}"
        end
      end
    end

    def verify_acceptance_test(controlrepo,test)
      require 'yaml'
      nodeset = YAML.load_file(controlrepo.nodeset_file)
      test.nodes.each do |node|
        unless nodeset['HOSTS'].has_key?(node)
          raise "Could not find nodeset for test: #{test.to_s}"
        end
      end
    end

    def pre_condition
      # Read all the pre_conditions and return the string
      spec_dir = Controlrepo.new.spec_dir
      puppetcode = []
      Dir["#{spec_dir}/pre_conditions/*.pp"].each do |condition_file|
        puppetcode << File.read(condition_file)
      end
      return false if puppetcode.count == 0
      puppetcode.join("\n")
    end

    def r10k_deploy_local(repo = Controlrepo.new)
      require 'controlrepo'
      tempdir = Dir.mktmpdir('r10k')
      repo.tempdir = tempdir

      # Read in the config and change all the directories, then create them
      r10k_config = repo.r10k_config
      r10k_config[:cachedir] = "#{tempdir}#{r10k_config[:cachedir]}"
      FileUtils::mkdir_p(r10k_config[:cachedir])
      r10k_config[:sources].map do |name,source_settings|
        source_settings["basedir"] = "#{tempdir}#{source_settings["basedir"]}"
        FileUtils::mkdir_p(source_settings["basedir"])
        # Yes, I realise this is going to set it many times
        repo.temp_environmentpath = source_settings["basedir"]
      end
      File.write("#{tempdir}/r10k.yaml",r10k_config.to_yaml)

      # Pull the trigger!
      Dir.chdir(tempdir) do
        `r10k deploy environment #{@environment} -p --color --config #{tempdir}/r10k.yaml --verbose`
      end

      # Return tempdir for use
      tempdir
    end

    def write_spec_test(location, test)
      # Use an ERB template to write a spec test
      template_dir = File.expand_path('../../templates',File.dirname(__FILE__))
      spec_template = File.read(File.expand_path('./test_spec.rb.erb',template_dir))
      randomness = (0...6).map { (65 + rand(26)).chr }.join
      File.write("#{location}/#{randomness}_#{test.to_s}_spec.rb",ERB.new(spec_template, nil, '-').result(binding))
    end

    def write_acceptance_tests(location, tests)
      template_dir = File.expand_path('../../templates',File.dirname(__FILE__))
      acc_test_template = File.read(File.expand_path('./acceptance_test_spec.rb.erb',template_dir))
      File.write("#{location}/acceptance_spec.rb",ERB.new(acc_test_template, nil, '-').result(binding))
    end

    def write_spec_helper_acceptance(location, repo)
      template_dir = File.expand_path('../../templates',File.dirname(__FILE__))
      spec_heler_acc_template = File.read(File.expand_path('./spec_helper_acceptance.rb.erb',template_dir))
      File.write("#{location}/spec_helper_acceptance.rb",ERB.new(spec_heler_acc_template, nil, '-').result(binding))
    end

    def write_rakefile(location, pattern)
      template_dir = File.expand_path('../../templates',File.dirname(__FILE__))
      rakefile_template = File.read(File.expand_path('./Rakefile.erb',template_dir))
      File.write("#{location}/Rakefile",ERB.new(rakefile_template, nil, '-').result(binding))
    end

    def write_gemfile(location)
      template_dir = File.expand_path('../../templates',File.dirname(__FILE__))
      gemfile_template = File.read(File.expand_path('./Gemfile.erb',template_dir))
      File.write("#{location}/Gemfile",ERB.new(gemfile_template, nil, '-').result(binding))
    end

    def write_spec_helper(location, repo)
      environmentpath = repo.temp_environmentpath
      modulepath = repo.config['modulepath']
      modulepath.delete("$basemodulepath")
      modulepath.map! do |path|
        "#{environmentpath}/#{@environment}/#{path}"
      end
      modulepath = modulepath.join(":")
      repo.temp_modulepath = modulepath

      # Use an ERB template to write a spec test
      template_dir = File.expand_path('../../templates',File.dirname(__FILE__))
      spec_helper_template = File.read(File.expand_path('./spec_helper.rb.erb',template_dir))
      File.write("#{location}/spec_helper.rb",ERB.new(spec_helper_template, nil, '-').result(binding))
    end

    def create_fixtures_symlinks(repo)
      FileUtils.mkdir_p("#{repo.tempdir}/spec/fixtures/modules")
      repo.temp_modulepath.split(':').each do |path|
        Dir["#{path}/*"].each do |mod|
          modulename = File.basename(mod)
          FileUtils.ln_s(mod, "#{repo.tempdir}/spec/fixtures/modules/#{modulename}")
        end
      end
    end

    # TODO: Work out the best way to format the output
    # TODO: Look into bundling bundler into the temp dir
    # TODO: Write task for beaker tests *brace yourself* Dont forget about the beaker file you have
    # TODO: Compare the outlout of the beaker helper that I wrote
    #       with the output from the templated tests, us ethe better one
    #       bearing in minf that beaker has logger options that could help
  end
end