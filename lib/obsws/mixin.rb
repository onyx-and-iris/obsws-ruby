require_relative "util"

module OBSWS
  module Mixin
    module Meta
      include Util::String

      def make_field_methods(*params)
        params.each do |param|
          define_singleton_method(snakecase(param.to_s)) { @resp[param] }
        end
      end
    end

    class MetaObject
      include Mixin::Meta

      def initialize(resp, fields)
        @resp = resp
        @fields = fields
        make_field_methods(*fields)
      end

      def empty? = @fields.empty?

      def attrs = @fields.map { |f| snakecase(f.to_s) }
    end

    class Response < MetaObject; end
    # Represents a request response object

    class Data < MetaObject; end
    # Represents an event data object

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
