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
    expect(log).to be_empty
  end

  it 'does NOT log :info message' do
    expect { subject.info 'message' }.to_not raise_error
    expect(log).to be_empty
  end

  it 'does NOT log :warn message' do
    expect { subject.warn 'message' }.to_not raise_error
    expect(log).to be_empty
  end

  it 'does NOT log :error message' do
    expect { subject.error 'message' }.to_not raise_error
    expect(log).to be_empty
  end

  it 'does NOT log :fatal message' do
    expect { subject.fatal 'message' }.to_not raise_error
    expect(log).to be_empty
  end

  context 'logging methods' do
    it 'can be called with one argument: String' do
      expect { subject.info 'message' }.to_not raise_error
      expect(log).to be_empty
    end

    it 'can be called with one argument: Hash' do
      expect { subject.info m:'message' }.to_not raise_error
      expect(log).to be_empty
    end

    it 'can be called with two arguments: String, Hash' do
      expect { subject.info 'message', param: 'extra' }.to_not raise_error
      expect(log).to be_empty
    end

    it 'can be called with block returning one argument: String' do
      expect { subject.info { 'message' } }.to_not raise_error
      expect(log).to be_empty
    end

    it 'can be called with block returning one argument: Hash' do
      expect do
        subject.info { { m:'message' } }
      end.to_not raise_error
      expect(log).to be_empty
    end

    it 'can be called with block returning two arguments: String, Hash' do
      expect { subject.info { ['message', param: 'extra'] } }.to_not raise_error
      expect(log).to be_empty
    end
  end # logging methods

end
