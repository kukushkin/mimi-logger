module Mimi
  class Logger
    #
    # A mixin to include into your classes and modules.
    # Makes methods #logger and .logger available, referring to one global instance:
    #
    # class MyApp
    #   include Mimi::Logger::Instance
    #
    #   def something
    #     logger.info 'Doing something...'
    #   end
    # end
    #
    module Instance
      def self.included(base)
        # puts "Module #{self} included into #{base}"
        base.send(:define_method, :logger) { Mimi::Logger::Instance.instance }
        base.send(:define_singleton_method, :logger) { Mimi::Logger::Instance.instance }
      end

      # Returns a previously created logger instance, or initializes a new one
      #
      # @param args [Array] arguments to Logger initializer
      #
      def self.instance(*args)
        raise 'Mimi::Logger::Instance already initialized' if @logger && !args.empty?
        @logger ||= Mimi::Logger.new(*args)
      end
    end # module Instance
  end # class Logger
end # module Mimi
