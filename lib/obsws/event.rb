require "json"

require_relative "util"
require_relative "mixin"

module OBSWS
  module Events
    module SUBS
      NONE = 0
      GENERAL = (1 << 0)
      CONFIG = (1 << 1)
      SCENES = (1 << 2)
      INPUTS = (1 << 3)
      TRANSITIONS = (1 << 4)
      FILTERS = (1 << 5)
      OUTPUTS = (1 << 6)
      SCENEITEMS = (1 << 7)
      MEDIAINPUTS = (1 << 8)
      VENDORS = (1 << 9)
      UI = (1 << 10)

      def low_volume
        GENERAL | CONFIG | SCENES | INPUTS | TRANSITIONS | FILTERS | OUTPUTS |
          SCENEITEMS | MEDIAINPUTS | VENDORS | UI
      end

      INPUTVOLUMEMETERS = (1 << 16)
      INPUTACTIVESTATECHANGED = (1 << 17)
      INPUTSHOWSTATECHANGED = (1 << 18)
      SCENEITEMTRANSFORMCHANGED = (1 << 19)

      def high_volume
        INPUTVOLUMEMETERS | INPUTACTIVESTATECHANGED | INPUTSHOWSTATECHANGED |
          SCENEITEMTRANSFORMCHANGED
      end

      def all
        low_volume | high_volume
      end

      module_function :low_volume, :high_volume, :all
    end

    module Callbacks
      include Util

      def add_observer(observer)
        @observers = [] unless defined?(@observers)
        observer = [observer] if !observer.respond_to? :each
        observer.each { |o| @observers.append(o) }
      end

      def remove_observer(observer)
        @observers.delete(observer)
      end

      def notify_observers(event, data)
        if defined?(@observers)
          @observers.each do |o|
            if o.respond_to? "on_#{event.to_snake}"
              if data.empty?
                o.send("on_#{event.to_snake}")
              else
                o.send("on_#{event.to_snake}", data)
              end
            end
          end
        end
      end
    end

    class Client
      include Callbacks
      include Mixin::TearDown
      include Mixin::OPCodes

      def initialize(**kwargs)
        kwargs[:subs] = SUBS.low_volume
        @base_client = Base.new(**kwargs)
        @base_client.add_observer(self)
      end

      def update(op_code, data)
        if op_code == Mixin::OPCodes::EVENT
          event = data[:eventType]
          data = data.key?(:eventData) ? data[:eventData] : {}
          notify_observers(event, Mixin::Data.new(data, data.keys))
        end
      end
    end
  end
end
