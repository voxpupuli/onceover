require 'controlrepo/class'
require 'controlrepo/node'
require 'controlrepo/group'

class Controlrepo
  class TestConfig
    require 'yaml'

    attr_accessor :classes
    attr_accessor :nodes
    attr_accessor :groups
    attr_accessor :test_matrix

    def initialize(file)
      begin
        config = YAML.load(File.read(file))
      rescue YAML::ParserError
        raise "Could not parse the YAML file, check that it is valid YAML and that the encoding is correct"
      end

      @classes =[]
      @nodes =[]
      @groups =[]
      @test_matrix = []
      
      config['classes'].each { |clarse| @classes << Controlrepo::Class.new(clarse) }
      config['nodes'].each { |node| @nodes << Controlrepo::Node.new(node) }
      config['groups'].each { |name, members| @groups << Controlrepo::Group.new(name, members) }
      #config['test_matrix'].each do |machines, roles|
        
      #@test_matrix = config['test_matrix']
    end
  end
end