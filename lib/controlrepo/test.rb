class Controlrepo
  class Test
    @@all =[]

    attr_accessor :nodes
    attr_accessor :classes
    attr_accessor :options
    attr_reader   :default_options

    # This can accept a bunch of stuff. It can accept nodes, classes or groups anywhere
    # it will then detect them and expand them out into their respective objects so that
    # we just end up with a list of nodes and classes
    def initialize(on_these,test_this,options = {})
      # Turn options into an empty hash is someone passed in a nil value
      options ||= {}

      # I copied this code off the internet, basically it allows us
      # to refer to each key as either a string or an object
      options.default_proc = proc do |h, k|
        case k
          when String then sym = k.to_sym; h[sym] if h.key?(sym)
          when Symbol then str = k.to_s; h[str] if h.key?(str)
        end
      end

      @default_options = {
        :check_idempotency => true,
        :runs_before_idempotency => 1
      }

      # Add defaults if they do not exist
      options = @default_options.merge(options)

      @nodes = []
      @classes = []
      @options = options

      # Get the nodes we are working on
      if Controlrepo::Group.find(on_these)
        @nodes << Controlrepo::Group.find(on_these).members
      elsif Controlrepo::Node.find(on_these)
        @nodes << Controlrepo::Node.find(on_these)
      else
        raise "#{on_these} was not found in the list of nodes or groups!"
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
      # This should take an array of tests and remove any duplicates from them

      # this will be an array of arrays, or maybe hashes
      # TODO: Rewrite this so that it merges options hashes, or takes one, decide on the right behaviour
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
              test.options.delete_if do |key,value|
                test.default_options[key] == value
              end

              # Merge the non-default options right on in there
              relevant_test.options.merge!(test.options)
            else
              combinations << combo
              new_tests << Controlrepo::Test.new(node,cls,test.options)
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
