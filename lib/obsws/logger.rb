require "logger"

module OBSWS
  module Logging
    def logger
      @logger = Logger.new($stdout, level: ENV.fetch("OBSWS_LOG_LEVEL", "WARN"))
      @logger.progname = instance_of?(::Module) ? name : self.class.name
      @logger
    end
  end
end
