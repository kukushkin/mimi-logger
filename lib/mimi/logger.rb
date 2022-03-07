
# frozen_string_literal: true

require 'forwardable'
require 'logger'
require 'json'
require 'securerandom'
require 'mimi/core'

module Mimi
  #
  # Mimi::Logger is a preconfigured logger which outputs log messages to STDOUT.
  #
  class Logger
    CONTEXT_ID_SIZE = 8 # bytes
    CONTEXT_ID_THREAD_VARIABLE = 'mimi_logger_context_id'

    extend Forwardable
    include Mimi::Core::Module

    attr_reader :logger_instance, :options

    delegate %i[debug? info? warn? error? fatal? << add log] => :logger_instance
    delegate %i[context_id context_id= new_context! with_new_context with_preserved_context] => self

    # Mimi::logger module manifest
    #
    def self.manifest
      {
        logger_format: {
          desc: 'String or JSON',
          default: 'json',
          hidden: true
        },
        logger_context: {
          desc: 'Logger will log context',
          type: :boolean,
          default: true,
          hidden: true
        },
        logger_level: {
          desc: 'Logger severity level threshold',
          default: 'info',
          type: ['debug', 'info', 'warn', 'error', 'fatal']
        },
        logger_cr_character: {
          desc: 'Logger replaces new line with alternative CR character',
          default: '↲', # alternative CR: ↵ ↲ ⏎
          type: :string,
          hidden: true
        }
      }
    end

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
      io = args.shift if args.first.is_a?(IO) || args.first.is_a?(StringIO)
      io ||= STDOUT
      opts = args.shift if args.first.is_a?(Hash)
      opts ||= {}
      raise ArgumentError, '(io, opts) are expected as parameters' unless args.empty?

      # module configured?
      self.class.configure() if self.class.options.empty?

      @options = self.class.options.deep_merge(opts)
      @logger_instance = ::Logger.new(io)
      @logger_instance.level = self.class.level_from_any(options[:logger_level])
      io.sync = true if io.respond_to?(:sync=)
      @logger_instance.formatter = self.class.formatter(options)
    end

    # Returns the current log level
    #
    # @return [Integer]
    #
    def level
      logger_instance.level
    end

    # Sets the log level.
    # Allows setting the log level from a String or a Symbol, in addition to the standard ::Logger::INFO etc.
    #
    # @param [String,Symbol,Integer] value
    #
    def level=(value)
      logger_instance.level = self.class.level_from_any(value)
    end

    # Logs a new message at the corresponding logging level
    #
    def debug(*args, &block)
      logger_instance.debug(args, &block)
    end

    # Logs a new message at the corresponding logging level
    #
    def info(*args, &block)
      logger_instance.info(args, &block)
    end

    # Logs a new message at the corresponding logging level
    #
    def warn(*args, &block)
      logger_instance.warn(args, &block)
    end

    # Logs a new message at the corresponding logging level
    #
    def error(*args, &block)
      logger_instance.error(args, &block)
    end

    # Logs a new message at the corresponding logging level
    #
    def fatal(*args, &block)
      logger_instance.fatal(args, &block)
    end

    # Logs a new message at the corresponding logging level
    #
    def unknown(*args, &block)
      logger_instance.unknown(args, &block)
    end

    # Returns the log level inferred from value
    #
    # @param value [String,Symbol,Integer]
    #
    def self.level_from_any(value)
      return value if value.is_a?(Integer)

      ::Logger.const_get(value.to_s.upcase.to_sym)
    rescue NameError
      raise ArgumentError, "Invalid value for the log level: '#{value}'"
    end

    # Returns formatter Proc object depending on configured format
    #
    # @return [Proc]
    # @private
    #
    def self.formatter(local_options)
      case local_options[:logger_format].to_s
      when 'json'
        formatter_json(local_options)
      when 'string'
        formatter_string(local_options)
      else
        raise "Invalid format specified for Mimi::Logger: '#{local_options[:logger_format]}'"
      end
    end

    # Returns formatter for 'json' format
    #
    # @param options [Hash] logger options
    # @return [Proc]
    # @private
    #
    def self.formatter_json(local_options)
      proc do |severity, _datetime, _progname, message|
        h = formatter_message_args_to_hash(message)
        h[:c] = context_id if local_options[:logger_context]
        h[:s] = severity.to_s[0]
        JSON.dump(h) + "\n"
      end
    end

    # Returns formatter for 'string' format
    #
    # @param options [Hash] logger options
    # @return [Proc]
    # @private
    #
    def self.formatter_string(local_options)
      proc do |severity, _datetime, _progname, message|
        h = formatter_message_args_to_hash(message)
        parts = []
        parts << severity.to_s[0]
        parts << context_id if local_options[:logger_context]
        parts << h[:m].to_s.tr("\n", local_options[:logger_cr_character])
        parts << '...' unless h.except(:m).empty?
        parts.join(', ') + "\n"
      end
    end

    # Converts logger methods arguments passed in various forms to a message hash.
    #
    # Arguments to a logger may be passed in 6 different ways:
    # @example
    #   logger.info('String')
    #   logger.info('String', param1: '..and a Hash')
    #   logger.info(m: 'Just a Hash', param1: 'with optional data')
    #
    #   # and the same 3 ways in a block form
    #   logger.info { ... }
    #
    # This helper method converts all possible variations into one Hash, where key m: refers to the
    # message and the rest are optional parameters passed in a Hash argument.
    #
    # @return [Hash]
    # @private
    #
    def self.formatter_message_args_to_hash(message_args)
      message_args = message_args.is_a?(String) || message_args.is_a?(Hash) ? [message_args] : message_args
      if !message_args.is_a?(Array) || message_args.size > 2
        raise ArgumentError, "Mimi::Logger arguments expected to be Array of up to 2 elements: #{message_args.inspect}"
      end

      h = {}
      arg1 = message_args.shift
      arg2 = message_args.shift

      if arg1.is_a?(String)
        if arg2 && !arg2.is_a?(Hash)
          raise ArgumentError, 'Mimi::Logger arguments are expected to be one of (<String>, <Hash>, [<String>, <Hash>])'
        end
        h = arg2.dup || {}
        h[:m] = arg1
      elsif arg1.is_a?(Hash)
        if arg2
          raise ArgumentError, 'Mimi::Logger arguments are expected to be one of (<String>, <Hash>, [<String>, <Hash>])'
        end
        h = arg1.dup
      else
        raise ArgumentError, 'Mimi::Logger arguments are expected to be one of (<String>, <Hash>, [<String>, <Hash>])'
      end
      h
    end

    # Returns current context ID if set, otherwise generates and sets a new context ID
    # and returns it.
    #
    # Context ID is local to the current thread. It identifies a group of instructions
    # happening within same logical context, as a single operation. For example, processing
    # an incoming request may be seen as a single context.
    #
    # Context ID is logged with every message.
    #
    # @return [String] a hex encoded context ID
    #
    def self.context_id
      Thread.current[CONTEXT_ID_THREAD_VARIABLE] || new_context!
    end

    # Sets the new context ID to the given value
    #
    # @param id [String] a new context ID
    # @return [String]
    #
    def self.context_id=(id)
      Thread.current[CONTEXT_ID_THREAD_VARIABLE] = id
    end

    # Starts a new logging context, generates a new random context ID and sets it as current
    #
    # @return [String] a new context ID
    #
    def self.new_context!
      self.context_id = SecureRandom.hex(CONTEXT_ID_SIZE)
    end

    # Executes a given block and ensures the context is restored afterwards
    #
    # @example
    #   logger.context_id # => "5d11f7c483dcfb2a"
    #   logger.with_preserved_context do
    #     logger.context_id = "temporary-context"
    #     logger.context_id # => "temporary-context"
    #   end
    #   logger.context_id # => "5d11f7c483dcfb2a"
    #
    def self.with_preserved_context(&_block)
      preserved_context_id = context_id
      yield
    ensure
      self.context_id = preserved_context_id
    end

    # Executes a given block in a new context and restores the context afterwards
    #
    # @example
    #   logger.context_id # => "5d11f7c483dcfb2a"
    #   logger.with_new_context do
    #     logger.context_id # => "e211ef95633a04b5"
    #   end
    #   logger.context_id # => "5d11f7c483dcfb2a"
    #
    def self.with_new_context(&_block)
      with_preserved_context do
        new_context!
        yield
      end
    end
  end # class Logger
end # module Mimi

require_relative 'logger/version'
require_relative 'logger/null_logger'
require_relative 'logger/instance'
