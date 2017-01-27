class Onceover
  class Shared_example
    @@all = []

    attr_accessor :name
    def initialize(name)
      @name = name
      @@all << self
    end

    def self.find(shared_example_name)
      @@all.each do |se|
        if shared_example_name.is_a?(Onceover::Shared_example)
          if cls = shared_example_name
            return se
          end
        elsif ce.name == shared_example_name
          return se
        end
      end
      logger.warn "Shared Example #{shared_example_name} not found"
      nil
    end

    def self.all
      @@all
    end
  end
end
