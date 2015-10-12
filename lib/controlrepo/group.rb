require 'controlrepo/class'
require 'controlrepo/node'

class Controlrepo
  class Group
    @@all = []

    # Work out how to do class veriables so that I can keep track of all the groups easily
    attr_accessor :name
    attr_accessor :members

    # You need to pass in an array of strings for members, not objects, it will find the objects
    # by itself, and yes it will reference them, not just create additional ones, woo!
    def initialize(name = nil, members = [])
      @name = name
      @members = []

      if members.any?
        member_objects = []
        members.each do |member|
          # Try to find the type for each member
          if Controlrepo::Class.find(member)
            member_objects << Controlrepo::Class.find(member)
          elsif Controlrepo::Node.find(member)
            member_objects << Controlrepo::Node.find(member)
          else
            raise "#{member} was not found in the list of nodes or classes!"
          end
        end

        # Check that they are all the same type
        if member_objects.all? { |item| item.is_a?(Controlrepo::Class) }
          type = Controlrepo::Class
        elsif member_objects.all? { |item| item.is_a?(Controlrepo::Node) }
          type = Controlrepo::Node
        else
          binding.pry
          raise 'Groups must contain either all nodes or all classes. Either there was a mix, or something was spelled wrong'
        end

        # Smash it into the instance variable
        @members = member_objects
      end

      # Finally add it to the list of all grops
      @@all << self
    end
  end
end
