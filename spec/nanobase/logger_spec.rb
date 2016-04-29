require 'spec_helper'

describe Mimi::Logger do
  let(:string_buffer) { StringIO.new }
  let(:log) { string_buffer.rewind; string_buffer.readlines.join("\n") }

  subject { described_class.new(string_buffer) }

  it 'has a version number' do
    expect(Mimi::Logger::VERSION).not_to be nil
  end

  it 'can be created' do
    expect { described_class.new }.to_not raise_error
  end

  it 'accepts level as a String' do
    expect { subject.level = 'info' }.to_not raise_error
  end

  it 'accepts level as a Symbol' do
    expect { subject.level = 'info' }.to_not raise_error
  end

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
end
