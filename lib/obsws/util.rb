module OBSWS
  module Util
    module String
      def camelcase(s)
        s.split("_").map(&:capitalize).join
      end

      def snakecase(s)
        s
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .downcase
      end
    end
  end
end
