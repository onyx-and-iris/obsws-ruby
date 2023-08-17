require "digest/sha2"
require "json"
require "logger"
require "securerandom"
require "socket"
require "waitutil"
require "websocket/driver"

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
    attr_reader :req_name, :code

    def initialize(req_name, code, comment)
      @req_name = req_name
      @code = code
      message = "Request #{req_name} returned code #{code}."
      message << " With message: #{comment}" if comment
      super(message)
    end
  end
end
