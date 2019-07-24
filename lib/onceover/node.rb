require 'onceover/controlrepo'

class Onceover
  class Node
    @@all = []


    attr_accessor :name
    attr_accessor :fact_set
    attr_accessor :trusted_set
    attr_accessor :provisioner
    attr_accessor :image
    attr_accessor :params
    attr_accessor :inventory_object

    def initialize(details)
      # If it's a string assume it has no options
      details = {details => {}} if details.is_a? String

      @name        = details.keys.first
      @provisioner = details[@name]['provisioner']
      @image       = details[@name]['image']
      @params      = details[@name]['params'] || {}

      # If we can't find the factset it will fail, so just catch that error and ignore it
      begin
        facts_file_index = Onceover::Controlrepo.facts_files.index {|facts_file|
          File.basename(facts_file, '.json') == @name
        }  
        @fact_set    = Onceover::Node.clean_facts(Onceover::Controlrepo.facts[facts_file_index])
        @trusted_set = Onceover::Controlrepo.trusted_facts[facts_file_index]
      rescue TypeError
        @fact_set    = nil
        @trusted_set = nil
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
      log.warn "Node #{node_name} not found"
      nil
    end

    def self.all
      @@all
    end

    # This method ensures that all facts are valid and clean anoything that we can't handle
    def self.clean_facts(factset)
      factset.delete('environment')
      factset
    end
  end
end
