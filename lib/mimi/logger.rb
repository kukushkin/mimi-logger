require 'forwardable'
require 'logger'
require 'mimi/core'

module Mimi
  #
  # Mimi::Logger is a preconfigured logger which outputs log messages to STDOUT.
  #
  class Logger
    extend Forwardable
    include Mimi::Core::Module

    attr_reader :logger_instance
    delegate [
      :debug, :info, :warn, :error, :fatal, :unknown,
      :debug?, :info?, :warn?, :error?, :fatal?,
      :<<, :add, :log
    ] => :logger_instance

    default_options(
      level: 'info',
      cr_character: '↲' # alternative CR: ↵ ↲ ⏎
    )

    # Creates a new Logger instance
    #
    # @param [IO] io An IO object to output log messages to, defaults to STDOUT
    # @param [Hash] opts
    # @option [String,Symbol,Integer] :level Initial log level, e.g. 'info'
    #
    # @example
    #   logger = Mimi::Logger.new
    #   logger.info 'I am a banana!' # outputs "I, I am a banana!" to the STDOUT
    #
    #   logger = Mimi::Logger.new(level: :debug)
    #   logger.debug 'blabla' # => "D, blabla"
    #
    def initialize(*args)
      io = args.shift if args.first.is_a?(IO)
      io ||= STDOUT
      opts = args.shift if args.first.is_a?(Hash)
      opts ||= {}
      raise ArgumentError, '(io, opts) are expected as parameters' unless args.empty?

      opts = self.class.module_options.deep_merge(opts)
      @logger_instance = ::Logger.new(io)
      @logger_instance.level = self.class.level_from_any(opts[:level])
      io.sync if io.respond_to?(:sync)
      @logger_instance.formatter = self.class.formatter
    end

    # Returns the current log level
    #
    # @return [Fixnum]
    #
    def level
      logger_instance.level
    end

    # Sets the log level.
    # Allows setting the log level from a String or a Symbol, in addition to the standard ::Logger::INFO etc.
    #
    # @param [String,Symbol,Fixnum] value
    #
    def level=(value)
      logger_instance.level = self.class.level_from_any(value)
    end

    # Returns the log level inferred from value
    #
    # @param value [String,Symbol,Fixnum]
    #
    def self.level_from_any(value)
      return value if value.is_a?(Fixnum)
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
      when :unknown
        ::Logger::UNKNOWN
      else
        raise ArgumentError, "Invalid value for the log level: '#{value}'"
      end
    end

    def self.formatter
      proc do |severity, _datetime, _progname, message|
        "#{severity.to_s[0]}, #{message.to_s.tr("\n", module_options[:cr_character])}\n"
      end
    end
  end # class Logger
end # module Mimi

require_relative 'logger/version'
require_relative 'logger/null_logger'
require_relative 'logger/instance'
