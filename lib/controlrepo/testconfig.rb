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

      # Set variables
      @classes     = config['classes']
      @nodes       = config['nodes']
      @groups      = config['groups']
      @test_matrix = config['test_matrix']
    end
  end
end