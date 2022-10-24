require "socket"
require "websocket/driver"
require "digest/sha2"
require "json"
require "observer"
require "waitutil"

require_relative "mixin"
require_relative "error"

module OBSWS
  class Socket
    attr_reader :url

    def initialize(url, socket)
      @url = url
      @socket = socket
    end

    def write(s)
      @socket.write(s)
    end
  end

  class Base
    include Observable
    include Mixin::OPCodes

    attr_reader :id, :driver, :closed

    def initialize(**kwargs)
      host = kwargs[:host] || "localhost"
      port = kwargs[:port] || 4455
      @password = kwargs[:password] || ""
      @subs = kwargs[:subs] || 0

      @socket = TCPSocket.new(host, port)
      @driver =
        WebSocket::Driver.client(Socket.new("ws://#{host}:#{port}", @socket))
      @driver.on :open do |msg|
        LOGGER.debug("driver socket open")
      end
      @driver.on :close do |msg|
        LOGGER.debug("driver socket closed")
        @closed = true
      end
      @driver.on :message do |msg|
        LOGGER.debug("received [#{msg}] passing to handler")
        msg_handler(JSON.parse(msg.data, symbolize_names: true))
      end
      start_driver
      WaitUtil.wait_for_condition(
        "waiting successful identification",
        delay_sec: 0.01,
        timeout_sec: 3
      ) { @identified }
    end

    def start_driver
      Thread.new do
        @driver.start

        loop do
          @driver.parse(@socket.readpartial(4096))
        rescue EOFError
          break
        end
      end
    end

    def auth_token(salt:, challenge:)
      Digest::SHA256.base64digest(
        Digest::SHA256.base64digest(@password + salt) + challenge
      )
    end

    def identify(auth)
      LOGGER.info("initiating authentication") if auth
      payload = {
        op: Mixin::OPCodes::IDENTIFY,
        d: {
          rpcVersion: 1,
          eventSubscriptions: @subs
        }
      }
      payload[:d][:authentication] = auth_token(**auth) if auth
      @driver.text(JSON.generate(payload))
    end

    def msg_handler(data)
      case data[:op]
      when Mixin::OPCodes::HELLO
        identify(data[:d][:authentication])
      when Mixin::OPCodes::IDENTIFIED
        @identified = true
      when Mixin::OPCodes::EVENT, Mixin::OPCodes::REQUESTRESPONSE
        changed
        notify_observers(data[:op], data[:d])
      end
    end

    def req(id, type_, data = nil)
      payload = {
        op: Mixin::OPCodes::REQUEST,
        d: {
          requestType: type_,
          requestId: id
        }
      }
      payload[:d][:requestData] = data if data
      queued = @driver.text(JSON.generate(payload))
      LOGGER.debug("request with id #{id} queued? #{queued}")
    end
  end
end
