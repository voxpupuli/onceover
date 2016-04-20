class Controlrepo
  class Test
    @@all =[]

    attr_accessor :nodes
    attr_accessor :classes
    attr_accessor :test_config
    attr_reader   :default_test_config
    attr_reader   :tags

    # This can accept a bunch of stuff. It can accept nodes, classes or groups anywhere
    # it will then detect them and expand them out into their respective objects so that
    # we just end up with a list of nodes and classes
    #def initialize(on_this,test_config['classes'],options = {})
    def initialize(on_this,test_this,test_config)

      @default_test_config = {
        'check_idempotency' => true,
        'runs_before_idempotency' => 1
      }

      # Add defaults if they do not exist
      test_config = @default_test_config.merge(test_config)

      @nodes = []
      @classes = []
      @test_config = test_config
      @test_config.delete('classes') # remove classes from the config
      @tags = @test_config['tags']


      # Make sure that tags are an array
      @test_config['tags'] = [@test_config['tags']].flatten if @test_config['tags']

      # Get the nodes we are working on
      if Controlrepo::Group.find(on_this)
        @nodes << Controlrepo::Group.find(on_this).members
      elsif Controlrepo::Node.find(on_this)
        @nodes << Controlrepo::Node.find(on_this)
      else
        raise "#{on_this} was not found in the list of nodes or groups!"
      end

      @nodes.flatten!

      # Check that our nodes list contains only nodes
      raise "#{@nodes} contained a non-node object." unless @nodes.all? { |item| item.is_a?(Controlrepo::Node) }

      if test_this.is_a?(String)
        # If we have just given a string then grab all the classes it corresponds to
        if Controlrepo::Group.find(test_this)
          @classes << Controlrepo::Group.find(test_this).members
        elsif Controlrepo::Class.find(test_this)
          @classes << Controlrepo::Class.find(test_this)
        else
          raise "#{test_this} was not found in the list of classes or groups!"
        end
        @classes.flatten!
      elsif test_this.is_a?(Hash)
        # If it is a hash we need to get creative

        # Get all of the included classes and add them
        if Controlrepo::Group.find(test_this['include'])
          @classes << Controlrepo::Group.find(test_this['include']).members
        elsif Controlrepo::Class.find(test_this['include'])
          @classes << Controlrepo::Class.find(test_this['include'])
        else
          raise "#{test_this['include']} was not found in the list of classes or groups!"
        end
        @classes.flatten!

        # Then remove any excluded ones
        if Controlrepo::Group.find(test_this['exclude'])
          Controlrepo::Group.find(test_this['exclude']).members.each do |clarse|
            @classes.delete(clarse)
          end
        elsif Controlrepo::Class.find(test_this['exclude'])
          @classes.delete(Controlrepo::Class.find(test_this['exclude']))
        else
          raise "#{test_this['exclude']} was not found in the list of classes or groups!"
        end
      elsif test_this.is_a?(Controlrepo::Class)
        @classes << test_this
      end
    end

    def eql?(other)
      (@nodes.sort.eql?(other.nodes.sort)) and (@classes.sort.eql?(other.classes.sort))
    end

    def to_s
      class_msg = ""
      node_msg = ""
      if classes.count > 1
        class_msg = "#{classes.count}_classes"
      else
        class_msg = classes[0].name
      end

      if nodes.count > 1
        node_msg = "#{nodes.count}_nodes"
      else
        node_msg = nodes[0].name
      end

      "#{class_msg}_on_#{node_msg}"
    end

    def self.deduplicate(tests)
      require 'deep_merge'
      # This should take an array of tests and remove any duplicates from them

      # this will be an array of arrays, or maybe hashes
      combinations = []
      new_tests = []
      tests.each do |test|
        test.nodes.each do |node|
          test.classes.each do |cls|
            combo = {node => cls}
            if combinations.member?(combo)

              # Find the right test object:
              relevant_test = new_tests[new_tests.index do |a|
                a.nodes[0] == node and a.classes[0] == cls
              end]

              # Delete all default values in the current options hash
              test.test_config.delete_if do |key,value|
                test.default_test_config[key] == value
              end

              # Merge the non-default options right on in there
              relevant_test.test_config.deep_merge!(test.test_config)
            else
              combinations << combo
              new_tests << Controlrepo::Test.new(node,cls,test.test_config)
            end
          end
        end
      end

      # The array that this returns should be ephemeral, it does not
      # represent anything defined in a controlrepo and should just
      # be passed into the thing doing the testing and then killed,
      # we don't want too many copies of the same shit going around
      #
      # Actually based on the way things are written I don't think this
      # will duplicated node or class objects, just test objects,
      # everything else is passed by reference
      new_tests
    end

    def self.all
      @@all
    end
  end
end
