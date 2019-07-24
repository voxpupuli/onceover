require 'logging'

class Onceover
  module Logger
    # Create the logging config inside a Onceover-specific namespace
    Logging.color_scheme('onceover_bright',
      :levels => {
        :debug => :cyan,
        :info  => :green,
        :warn  => :yellow,
        :error => :red,
        :fatal => [:white, :on_red]
      }
    )

    Logging.appenders.stdout(
      'onceover',
      :layout => Logging.layouts.pattern(
        :pattern      => '%l\t -> %m\n',
        :color_scheme => 'onceover_bright'
      )
    )

    # Create the logger and set the initial settings
    Logging.logger['Onceover']
    Logging.logger['Onceover'].appenders = 'onceover'

      # "log" is now the used logger, this is provided for backward compatibility
    def logger
      Logging.logger['Onceover']
    end

    def log
      Logging.logger['Onceover']
    end

    def log_reset_appenders!
      Logging.logger['Onceover'].appenders = []
      Logging.logger['Onceover'].appenders = 'onceover'
    end
  end
end
