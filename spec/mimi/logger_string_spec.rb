require 'spec_helper'

describe Mimi::Logger, 'with string format' do
  let(:string_buffer) { StringIO.new }
  let(:log) { string_buffer.rewind; string_buffer.readlines.join }
  let(:logger_format) { :string }
  let(:logger_log_context) { false }

  before do
    described_class.module_options[:format] = logger_format
    described_class.module_options[:log_context] = logger_log_context
  end

  subject { described_class.new(string_buffer) }

  it 'can be created' do
    expect { described_class.new }.to_not raise_error
  end

  it 'logs two events separated by a single new line' do
    subject.info 'message1'
    subject.info 'message2'
    expect(log.split("\n").size).to be 2
  end

  context 'logging methods' do
    it 'can be called with one argument: String' do
      expect { subject.info 'message' }.to_not raise_error
      expect(log).to match(/^I, message/)
    end

    it 'can be called with one argument: Hash' do
      expect { subject.info m:'message' }.to_not raise_error
      expect(log).to match(/^I, message/)
    end

    it 'can be called with two arguments: String, Hash' do
      expect { subject.info 'message', param: 'extra' }.to_not raise_error
      expect(log).to match(/^I, message,/)
    end

    it 'can be called with block returning one argument: String' do
      expect { subject.info { 'message' } }.to_not raise_error
      expect(log).to match(/^I, message/)
    end

    it 'can be called with block returning one argument: Hash' do
      expect do
        subject.info { { m:'message' } }
      end.to_not raise_error
      expect(log).to match(/^I, message/)
    end

    it 'can be called with block returning two arguments: String, Hash' do
      expect { subject.info { ['message', param: 'extra'] } }.to_not raise_error
      expect(log).to match(/^I, message,/)
    end
  end # logging methods

  context 'with context logging' do
    let(:logger_log_context) { true }

    it 'logs :debug message' do
      subject.level = :debug
      expect { subject.debug 'message' }.to_not raise_error
      expect(log).to match(/^D, [0-9a-f]+, message/)
    end

    it 'logs :info message' do
      expect { subject.info 'message' }.to_not raise_error
      expect(log).to match(/^I, [0-9a-f]+, message/)
    end

    it 'logs :warn message' do
      expect { subject.warn 'message' }.to_not raise_error
      expect(log).to match(/^W, [0-9a-f]+, message/)
    end

    it 'logs :error message' do
      expect { subject.error 'message' }.to_not raise_error
      expect(log).to match(/^E, [0-9a-f]+, message/)
    end

    it 'logs :fatal message' do
      expect { subject.fatal 'message' }.to_not raise_error
      expect(log).to match(/^F, [0-9a-f]+, message/)
    end
  end # with context logging

  context 'without context logging' do
    let(:logger_log_context) { false }

    it 'logs :debug message' do
      subject.level = :debug
      expect { subject.debug 'message' }.to_not raise_error
      expect(log).to match(/^D, message/)
    end

    it 'logs :info message' do
      expect { subject.info 'message' }.to_not raise_error
      expect(log).to match(/^I, message/)
    end

    it 'logs :warn message' do
      expect { subject.warn 'message' }.to_not raise_error
      expect(log).to match(/^W, message/)
    end

    it 'logs :error message' do
      expect { subject.error 'message' }.to_not raise_error
      expect(log).to match(/^E, message/)
    end

    it 'logs :fatal message' do
      expect { subject.fatal 'message' }.to_not raise_error
      expect(log).to match(/^F, message/)
    end
  end # without context logging
end
