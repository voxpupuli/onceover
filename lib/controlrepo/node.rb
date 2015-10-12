class Controlrepo
  class Node
    @@all = []


    attr_accessor :name
    attr_accessor :beaker_node

    def initialize(name)
      @name = name
      @beaker_node = nil
      @@all << self
    end

    def self.find(node_name)
      @@all.each do |node|
        if node.name == node_name
          return node
        end
        nil
      end
    end
  end
end