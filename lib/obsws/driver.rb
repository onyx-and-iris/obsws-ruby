require "socket"
require "websocket/driver"

module OBSWS
  module Driver
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

    def setup_driver(host, port)
      @socket = TCPSocket.new(host, port)
      @driver =
        WebSocket::Driver.client(Socket.new("ws://#{host}:#{port}", @socket))
      @driver.on :open do |msg|
        logger.debug("driver socket open")
      end
      @driver.on :close do |msg|
        logger.debug("driver socket closed")
        @closed = true
      end
      @driver.on :message do |msg|
        msg_handler(JSON.parse(msg.data, symbolize_names: true))
      end
    end

    private def start_driver
      Thread.new do
        @driver.start

        loop do
          @driver.parse(@socket.readpartial(4096))
        rescue EOFError
          break
        end
      end
    end

    public def stop_driver
      @driver.close
    end
  end
end
