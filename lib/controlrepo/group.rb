require 'controlrepo/class'
require 'controlrepo/node'

class Controlrepo
  class Group
    # Work out how to do class veriables so that I can keep track of all the groups easily
    attr_accessor :name
    attr_accessor :members

    def initialize(name = nil, members = [])
      @name = name
      @members = []
      # find a better way of checking the types in are array
      if members.count != 0
        if members[0].is_a?(Controlrepo::Class)
          type = Controlrepo::Class
        else 
          type = Controlrepo::node
        end

        members.each do |member|
          @members << type.new(member)
        end
      end
    end
  end
end
