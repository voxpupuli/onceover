class Controlrepo
  class Class
    @@all = []

    attr_accessor :name
    def initialize(name)
      @name = name
      @@all << self
    end

    def self.find(class_name)
      @@all.each do |cls|
        if class_name.is_a?(Controlrepo::Class)
          if cls = class_name
            return cls
          end
        elsif cls.name == class_name
          return cls
        end
      end
      logger.warn "Class #{class_name} not found"
      nil
    end

    def self.all
      @@all
    end
  end
end
