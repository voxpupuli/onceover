class Onceover
  class Class
    @@all = []

    attr_accessor :name

    def initialize(name)
      # if the class we are trying to create is a regex, create class objects
      # for everything that matches.
      if Onceover::Class.name_is_regexp?(name)
        expression = Onceover::Class.string_to_regexp(name)
        matched_classes = Onceover::Controlrepo.classes.keep_if { |c| c =~ expression }
        matched_classes.each do |c|
          Onceover::Class.new(c)
        end
      else
        @name = name
        @@all << self
      end
    end

    # This is what is executed to see if something exists as a class. The same
    # thing is executed for groups etc. when building up test matricies.
    def self.find(class_name)
      if Onceover::Class.name_is_regexp?(class_name)
        return @@all.select do |cls|
          cls.name =~ Onceover::Class.string_to_regexp(class_name)
        end
      else
        @@all.each do |cls|
          if cls.name == class_name
            return cls
          end
        end
      end
      logger.warn "Class #{class_name} not found"
      nil
    end

    def self.all
      @@all
    end

    def self.string_to_regexp(string)
      if Onceover::Class.name_is_regexp?(string)
        Regexp.new(string[1..-2])
      else
        raise "#{string} does not start and end with / and cannot be converted to regexp"
      end
    end

    def self.name_is_regexp?(name)
      name.start_with?('/') and name.end_with?('/')
    end
  end
end
