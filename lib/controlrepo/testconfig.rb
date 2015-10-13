require 'controlrepo/class'
require 'controlrepo/node'
require 'controlrepo/group'
require 'controlrepo/test'

class Controlrepo
  class TestConfig
    require 'yaml'

    attr_accessor :classes
    attr_accessor :nodes
    attr_accessor :groups
    attr_accessor :tests

    def initialize(file)
      begin
        config = YAML.load(File.read(file))
      rescue YAML::ParserError
        raise "Could not parse the YAML file, check that it is valid YAML and that the encoding is correct"
      end

      @classes =[]
      @nodes =[]
      @groups =[]
      @tests = []
      
      config['classes'].each { |clarse| @classes << Controlrepo::Class.new(clarse) }
      config['nodes'].each { |node| @nodes << Controlrepo::Node.new(node) }
      config['groups'].each { |name, members| @groups << Controlrepo::Group.new(name, members) }

      # Add the 'all_classes' and 'all_nodes' default groups
      @groups << Controlrepo::Group.new('all_nodes',@nodes)
      @groups << Controlrepo::Group.new('all_classes',@classes)

      # TODO: Consider renaming test_matrix
      config['test_matrix'].each do |machines, roles|
        @tests << Controlrepo::Test.new(machines,roles)
      end
    end

    def r10k_deploy_local(repo = Controlrepo.new)
      require 'controlrepo'
      tempdir = Dir.mktmpdir('r10k')

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
        `r10k deploy environment -p --color --config #{tempdir}/r10k.yaml --verbose`
      end

      # Return tempdir for use
      tempdir
    end

    def write_spec_test(test)
      # Use an ERB template to write a spec test
      template_dir = File.expand_path('../../templates',File.dirname(__FILE__))
      spec_template = File.read(File.expand_path('./test_spec.rb.erb',template_dir))
      output_file = Tempfile.new(['test','_spec.rb'])
      File.write(output_file,ERB.new(spec_template, nil, '-').result(binding))
      output_file
    end

    def run_tests(repo)
      require 'puppetlabs_spec_helper/puppet_spec_helper'
      require 'rspec-puppet'

      RSpec.configure do |c|
        c.hiera_config = repo.hiera_config_file
        c.environmentpath = repo.temp_environmentpath
      end

      binding.pry
    end
  end
end