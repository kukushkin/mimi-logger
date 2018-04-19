# mimi-logger

A pre-configured logger for microservice applications.

[in development]

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mimi-logger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mimi-logger

## Usage

```ruby
require 'mimi/logger'

logger = Mimi::Logger.new format: :string

logger.info 'I am a banana!' # outputs "I, I am a banana!" to STDOUT
```

### Logging format

Since v0.2.0 the default format for logging is JSON:

```ruby
require 'mimi/logger'

logger = Mimi::Logger.new

logger.info 'I am a banana' # => '{"s":"I","m":"I am a banana","c":"60eecc2e764fe2f6"}'
```

The following properties of a serialized JSON object are reserved:

name | description
-----|------------
  s  | severity, one of D,I,W,E,F
  m  | message
  c  | context ID, 8 bytes hex encoded

Additional properties may be provided by the caller and they will be included in the logged JSON:

```ruby
require 'mimi/logger'

logger = Mimi::Logger.new

t_start = Time.now
... # work, work
logger.info 'Jobs done', t: Time.now - t_start
# => '{"s":"I","m":"Jobs done","c":"60eecc2e764fe2f6", "t": 13.794034499}'
```

### How to log structured data

There are multiple ways to log an event. The first and the simplest one is to log just a text
message:

```ruby
require 'mimi/logger'

logger = Mimi::Logger.new

logger.info 'I am a banana'
# or using a block variant
logger.debug { 'Debug this banana' }
```

Alternatively you can log a structured object, by passing a Hash in addition to the message:

```ruby
require 'mimi/logger'

logger = Mimi::Logger.new

logger.info 'I am a banana', banana: { id: 123, weight: 456 }
# => {"s":"I","m":"I am a banana","c":"d8b6f859bf9d0190","banana":{"id":123,"weight":456}}
```

Or specify the object/Hash explicitly:
```ruby
...
logger.info m: 'I am a banana', banana: { id: 123, weight: 456 }
```

Or with a block variant:
```ruby
...
logger.debug do
  { banana: { id: 123, weight: 456 } }
end

# a block can also return an Array of one (Hash) or two (String,Hash) elements:
logger.debug { [m: 'Debug this banana', banana: { id: 123, weight: 456 }] }
logger.debug { ['Debug this banana', banana: { id: 123, weight: 456 }] }
```

### Logging context

Logging context refers to a set of instructions that are somehow logically grouped. For example,
the whole logic processing an incoming web request can be seen as operating within a single context
of this particular web request. In a distributed or a multithreaded application it would be beneficial
to identify logged messages produced within same context, otherwise the messages related to different
web requests will be interleaved and understanding the flow, the cause and effect would be very difficult.

To solve this problem, Mimi::Logger allows for setting an arbitrary (or random) context ID, which is local
to the current thread, and which is included in every logged message.

A new context may be initiated by `.new_context_id!`:

```ruby
require 'mimi/logger'

logger = Mimi::Logger.new

logger.info 'I am a banana!'
logger.new_context_id!
logger.info 'I am a banana!' # this is not the same banana, it's from a different context
```

Or it can be set to an explicit value:

```ruby
require 'mimi/logger'

logger = Mimi::Logger.new

logger.info 'I am a banana!'
logger.context_id = 'different-context!'
logger.info 'I am a banana!' # this is not the same banana, it's from a 'different-context!'

```

#### Context ID in a multithreaded application

The context ID is local to a current thread, so it's safe to start or assign a different context ID
in other threads of the application.

#### Context ID in a distributed application

If you have a distributed multicomponent application (e.g. microservice architecture), context ID
may help to track requests between multiple parties. In order to achieve it, you need to generate a
new context ID in the beginning of your processing and pass it along with all the requests/messages to
other components of the system. Upon receiving such a request, another application sets its local context ID
to the received value and continues.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kukushkin/mimi-logger. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

