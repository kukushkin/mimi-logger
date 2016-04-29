module Mimi
  class Logger
    class NullLogger
      def initialize(*)
      end

      def debug(*)
      end

      def info(*)
      end

      def warn(*)
      end

      def error(*)
      end

      def fatal(*)
      end

      def level; end

      def level=(*); end
    end # class NullLogger
  end # class Logger
end # module Mimi
