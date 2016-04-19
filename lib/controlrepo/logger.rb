require 'logging'

module Controlrepo::Logger
  def logger
    unless $logger
      $logger = Logging.logger(STDOUT)
      $logger.level = :warn
    end
    $logger
  end
end
