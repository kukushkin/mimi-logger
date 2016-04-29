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

logger = Mimi::Logger.new

logger.info 'I am a banana!' # outputs "I, I am a banana!" to STDOUT
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kukushkin/mimi-logger. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

