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

      def self.instance
        @logger ||= Mimi::Logger.new
      end
    end # module Instance
  end # class Logger
end # module Mimi
