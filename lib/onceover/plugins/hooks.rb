require 'onceover/plugins'

class Onceover
  class Plugins
    class Hooks
      def self.execute(name, object)
        plugins = Onceover::Plugins.new.plugins

        plugins.each do |plugin|
          class_name = plugin.split('-').map { |s| s.capitalize }.join('::')
          class_object = Object.const_get(class_name)

          if class_object.respond_to?(name)
            Object.const_get(class_name).send(name, object)
          end
        end
      end
    end
  end
end
