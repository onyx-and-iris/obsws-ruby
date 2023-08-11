require "digest/sha2"
require "json"
require "waitutil"
require "socket"
require "websocket/driver"
require "logger"

require_relative "obsws/logger"
require_relative "obsws/driver"
require_relative "obsws/util"
require_relative "obsws/mixin"
require_relative "obsws/base"

require_relative "obsws/req"
require_relative "obsws/event"

require_relative "obsws/version"

module OBSWS
  class OBSWSError < StandardError; end

  class OBSWSConnectionError < OBSWSError; end

  class OBSWSRequestError < OBSWSError
    attr_reader :name, :code

    def initialize(name, code, msg)
      @name = name
      @code = code
      @msg = msg
      super(message)
    end

    def message
      msg = [
        "Request #{@name} returned code #{@code}."
      ]
      msg << "With message: #{@msg}" if @msg
      msg.join(" ")
    end
  end
end
