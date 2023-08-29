module OBSWS
  module Mixin
    module Meta
      using Util::CoreExtensions

      def make_field_methods(*params)
        params.each do |param|
          define_singleton_method(param.to_s.snakecase) { @resp[param] }
        end
      end
    end

    class MetaObject
      using Util::CoreExtensions
      include Mixin::Meta

      def initialize(resp, fields)
        @resp = resp
        @fields = fields
        make_field_methods(*fields)
      end

      def empty? = @fields.empty?

      def attrs = @fields.map { |f| f.to_s.snakecase }
    end

    # Represents a request response object
    class Response < MetaObject; end

    # Represents an event data object
    class Data < MetaObject; end

    module TearDown
      def stop_driver
        @base_client.stop_driver
      end

      alias_method :close, :stop_driver
    end

    module OPCodes
      HELLO = 0
      IDENTIFY = 1
      IDENTIFIED = 2
      REIDENTIFY = 3
      EVENT = 5
      REQUEST = 6
      REQUESTRESPONSE = 7
      REQUESTBATCH = 8
      REQUESTBATCHRESPONSE = 9
    end
  end
end
