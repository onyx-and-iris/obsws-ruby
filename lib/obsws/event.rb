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

    module Callbacks
      include Util::String

      def observers
        @observers ||= []
      end

      def add_observer(observer)
        observer = [observer] unless observer.respond_to? :each
        observer.each { |o| observers << o unless observers.include? o }
      end

      def remove_observer(observer)
        observer = [observer] unless observer.respond_to? :each
        observers.reject! { |o| observer.include? o }
      end

      private def notify_observers(event, data)
        observers.each do |o|
          if o.is_a? Method
            if o.name.to_s == "on_#{snakecase(event)}"
              data.empty? ? o.call : o.call(data)
            end
          elsif o.respond_to? "on_#{snakecase(event)}"
            data.empty? ? o.send("on_#{snakecase(event)}") : o.send("on_#{snakecase(event)}", data)
          end
        end
      end

      alias_method :callbacks, :observers
      alias_method :register, :add_observer
      alias_method :deregister, :remove_observer
    end

    class Client
      include Logging
      include Callbacks
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
            notify_observers(event, Mixin::Data.new(data, data.keys))
          end
        }
      end

      def to_s
        self.class.name.split("::").last(2).join("::")
      end
    end
  end
end
