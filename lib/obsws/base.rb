module OBSWS
  class Identified
    attr_accessor :state

    def initialize
      @state = :pending
    end

    def error_message
      case @state
      when :passwordless
        "auth enabled but no password provided"
      else
        "failed to identify client with the websocket server"
      end
    end
  end

  class Base
    include Logging
    include Driver::Director
    include Mixin::OPCodes

    attr_reader :closed, :identified
    attr_writer :updater

    def initialize(**kwargs)
      host = kwargs[:host] || "localhost"
      port = kwargs[:port] || 4455
      @password = kwargs[:password] || ""
      @subs = kwargs[:subs] || 0
      @identified = Identified.new
      setup_driver(host, port) and start_driver
      WaitUtil.wait_for_condition(
        "successful identification",
        delay_sec: 0.01,
        timeout_sec: kwargs[:connect_timeout] || 3
      ) { @identified.state != :pending }
    end

    private

    def auth_token(salt:, challenge:)
      Digest::SHA256.base64digest(
        Digest::SHA256.base64digest(@password + salt) + challenge
      )
    end

    def identify(auth)
      payload = {
        op: Mixin::OPCodes::IDENTIFY,
        d: {
          rpcVersion: 1,
          eventSubscriptions: @subs
        }
      }
      if auth
        if @password.empty?
          @identified.state = :passwordless
          return
        end
        logger.info("initiating authentication")
        payload[:d][:authentication] = auth_token(**auth)
      end
      @driver.text(JSON.generate(payload))
    end

    def msg_handler(data)
      case data[:op]
      when Mixin::OPCodes::HELLO
        identify(data[:d][:authentication])
      when Mixin::OPCodes::IDENTIFIED
        @identified.state = :identified
      when Mixin::OPCodes::EVENT, Mixin::OPCodes::REQUESTRESPONSE
        @updater.call(data[:op], data[:d])
      end
    end

    public def req(id, type_, data = nil)
      payload = {
        op: Mixin::OPCodes::REQUEST,
        d: {
          requestType: type_,
          requestId: id
        }
      }
      payload[:d][:requestData] = data if data
      logger.debug("sending request: #{payload}")
      @driver.text(JSON.generate(payload))
    end
  end
end
