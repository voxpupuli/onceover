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
        if cls.name == class_name
          return cls
        end
      end
      nil
    end
  end
end