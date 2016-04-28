require 'onceover/controlrepo'

class Onceover
  class Node
    @@all = []


    attr_accessor :name
    attr_accessor :beaker_node
    attr_accessor :fact_set

    def initialize(name)
      @name = name
      @beaker_node = nil

      # If we can't find the factset it will fail, so just catch that error and ignore it
      begin
        @fact_set = Onceover::Controlrepo.facts[Onceover::Controlrepo.facts_files.index{|facts_file| File.basename(facts_file,'.json') == name}]
      rescue TypeError
        @fact_set = nil
      end
      @@all << self

    end

    def self.find(node_name)
      @@all.each do |node|
        if node_name.is_a?(Onceover::Node)
          if node = node_name
            return node
          end
        elsif node.name == node_name
          return node
        end
      end
      logger.warn "Node #{node_name} not found"
      nil
    end

    def self.all
      @@all
    end
  end
end
