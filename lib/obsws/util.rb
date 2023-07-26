module OBSWS
  module Util
    class ::String
      def to_camel
        split("_").map(&:capitalize).join
      end

      def to_snake
        gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .downcase
      end
    end
  end
end
