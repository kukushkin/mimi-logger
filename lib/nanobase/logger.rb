require 'forwardable'
require 'logger'

module Nanobase
  class Logger
    extend Forwardable

    attr_reader :logger_instance
    delegate [:debug, :info, :warn, :error, :fatal] => :logger_instance

    def initialize(io = STDOUT)
      @logger_instance = ::Logger.new(io)
      @logger_instance.level = ::Logger::INFO
      io.sync if io.respond_to?(:sync)
      @logger_instance.formatter = formatter
    end

    def level
      logger_instance.level
    end

    def level=(value)
      return logger_instance.level = value if value.is_a?(Fixnum)
      logger_instance.level =
        case value.to_s.downcase.to_sym
        when :debug
          ::Logger::DEBUG
        when :info
          ::Logger::INFO
        when :warn
          ::Logger::WARN
        when :error
          ::Logger::ERROR
        when :fatal
          ::Logger::FATAL
        else
          ::Logger::INFO
        end
      logger_instance.level
    end

    def formatter
      proc do |severity, _datetime, _progname, message|
        "#{severity[0]}, #{message}\n"
      end
    end
  end # class Logger
end # module Nanobase

require_relative 'logger/version'
require_relative 'logger/null_logger'
require_relative 'logger/instance'
