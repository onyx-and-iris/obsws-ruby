module OBSWS
  module Events
    module SUBS
      NONE = 0
      GENERAL = 1 << 0
      CONFIG = 1 << 1
      SCENES = 1 << 2
      INPUTS = 1 << 3
      TRANSITIONS = 1 << 4
      FILTERS = 1 << 5
      OUTPUTS = 1 << 6
      SCENEITEMS = 1 << 7
      MEDIAINPUTS = 1 << 8
      VENDORS = 1 << 9
      UI = 1 << 10

      LOW_VOLUME = GENERAL | CONFIG | SCENES | INPUTS | TRANSITIONS | FILTERS | OUTPUTS |
        SCENEITEMS | MEDIAINPUTS | VENDORS | UI

      INPUTVOLUMEMETERS = 1 << 16
      INPUTACTIVESTATECHANGED = 1 << 17
      INPUTSHOWSTATECHANGED = 1 << 18
      SCENEITEMTRANSFORMCHANGED = 1 << 19

      HIGH_VOLUME = INPUTVOLUMEMETERS | INPUTACTIVESTATECHANGED | INPUTSHOWSTATECHANGED |
        SCENEITEMTRANSFORMCHANGED

      ALL = LOW_VOLUME | HIGH_VOLUME
    end

    module EventDirector
      include Util::String

      def observers
        @observers ||= {}
      end

      def on(event, method = nil, &block)
        (observers[event] ||= []) << (block || method)
      end

      def register(cbs)
        cbs = Array(cbs) unless cbs.respond_to? :each
        cbs.each { |cb| on(cb.name[3..].to_sym, cb) }
      end

      def deregister(cbs)
        cbs = Array(cbs) unless cbs.respond_to? :each
        cbs.each { |cb| observers[cb.name[3..].to_sym]&.reject! { |o| cbs.include? o } }
      end

      def fire(event, data)
        observers[snakecase(event).to_sym]&.each { |block| data.empty? ? block.call : block.call(data) }
      end
    end

    class Client
      include Logging
      include EventDirector
      include Mixin::TearDown
      include Mixin::OPCodes

      def initialize(**kwargs)
        kwargs[:subs] ||= SUBS::LOW_VOLUME
        @base_client = Base.new(**kwargs)
        unless @base_client.identified.state == :identified
          err_msg = @base_client.identified.error_message
          logger.error(err_msg)
          raise OBSWSConnectionError.new(err_msg)
        end
        logger.info("#{self} successfully identified with server")
      rescue Errno::ECONNREFUSED, WaitUtil::TimeoutError => e
        msg = "#{e.class.name}: #{e.message}"
        logger.error(msg)
        raise OBSWSConnectionError.new(msg)
      else
        @base_client.updater = ->(op_code, data) {
          if op_code == Mixin::OPCodes::EVENT
            logger.debug("received: #{data}")
            event = data[:eventType]
            data = data.fetch(:eventData, {})
            fire(event, Mixin::Data.new(data, data.keys))
          end
        }
      end

      def to_s
        self.class.name.split("::").last(2).join("::")
      end
    end
  end
end
