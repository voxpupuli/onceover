require 'onceover/plugins'

class Onceover
  class Plugins
    class Hooks
      def self.execute(name)
        plugins = Onceover::Plugins.new.plugins

        plugins.each do |plugin|
          class_name = plugin.split('-').map { |s| s.capitalize }.join('::')
          Object.const_get(class_name).send(name)
        end
      end
    end
  end
end
