require 'logging'

module Controlrepo::Logger
  def logger
    unless $logger
      # here we setup a color scheme called 'bright'
      Logging.color_scheme( 'bright',
        :levels => {
          :debug => :cyan,
          :info  => :green,
          :warn  => :yellow,
          :error => :red,
          :fatal => [:white, :on_red]
        }
      )

      Logging.appenders.stdout(
        'stdout',
        :layout => Logging.layouts.pattern(
          :pattern => '%l\t -> %m\n',
          :color_scheme => 'bright'
        )
      )

      $logger = Logging.logger['Colors']
      $logger.add_appenders 'stdout'
      $logger.level = :warn
    end
    $logger
  end
end
