require "logger"

require_relative "obsws/req"
require_relative "obsws/event"

module OBSWS
  include Logger::Severity

  LOGGER = Logger.new(STDOUT)
  LOGGER.level = WARN
end
