require 'spec_helper'

describe Mimi::Logger::NullLogger do
  let(:string_buffer) { StringIO.new }
  let(:log) { string_buffer.rewind; string_buffer.readlines.join("\n") }

  subject { described_class.new(string_buffer) }

  it 'can be created' do
    expect { described_class.new }.to_not raise_error
  end

  it 'accepts level as a String' do
    expect { subject.level = 'info' }.to_not raise_error
  end

  it 'accepts level as a Symbol' do
    expect { subject.level = 'info' }.to_not raise_error
  end

  it 'does NOT log :debug message' do
    subject.level = :debug
    expect { subject.debug 'message' }.to_not raise_error
    expect(log).to_not match(/^D, message/)
  end

  it 'does NOT log :info message' do
    expect { subject.info 'message' }.to_not raise_error
    expect(log).to_not match(/^I, message/)
  end

  it 'does NOT log :warn message' do
    expect { subject.warn 'message' }.to_not raise_error
    expect(log).to_not match(/^W, message/)
  end

  it 'does NOT log :error message' do
    expect { subject.error 'message' }.to_not raise_error
    expect(log).to_not match(/^E, message/)
  end

  it 'does NOT log :fatal message' do
    expect { subject.fatal 'message' }.to_not raise_error
    expect(log).to_not match(/^F, message/)
  end
end
