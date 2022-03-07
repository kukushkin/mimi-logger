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
    expect { subject.level = :info }.to_not raise_error
  end

  context 'with logging context support' do
    let(:sample_context_id) { '00ff00ff' }
    let(:other_context_id) { 'ff00ff00' }

    it { is_expected.to respond_to(:context_id) }
    it { is_expected.to respond_to(:context_id=) }
    it { is_expected.to respond_to(:new_context!) }
    it { is_expected.to respond_to(:with_new_context) }
    it { is_expected.to respond_to(:with_preserved_context) }

    it 'allows setting a custom context ID' do
      expect { subject.context_id = sample_context_id }.to_not raise_error
      expect(subject.context_id).to eq sample_context_id
    end

    it 'allows starting a new context' do
      expect { subject.new_context! }.to_not raise_error
      expect { subject.new_context! }.to change { subject.context_id }
    end

    it 'allows running a block preserving context id' do
      subject.context_id = sample_context_id
      expect { subject.with_preserved_context {} }.to_not raise_error
      expect { subject.with_preserved_context {} }.to_not change { subject.context_id }
      subject.with_preserved_context do
        subject.context_id = other_context_id
        expect(subject.context_id).to_not eq sample_context_id
      end
      expect(subject.context_id).to eq sample_context_id
    end

    it 'allows running a block with a new temporary context' do
      subject.context_id = sample_context_id
      expect { subject.with_new_context {} }.to_not raise_error
      expect { subject.with_new_context {} }.to_not change { subject.context_id }
      subject.with_new_context do
        expect(subject.context_id).to_not eq sample_context_id
      end
      expect(subject.context_id).to eq sample_context_id
    end
  end # with logging context support

  describe '.level_from_any' do
    it 'can be called with a number' do
      expect(described_class.level_from_any(1)).to eq(1)
    end

    it 'can be called with :debug' do
      expect(described_class.level_from_any('debug')).to eq(::Logger::DEBUG)
    end

    it 'can be called with info' do
      expect(described_class.level_from_any('info')).to eq(::Logger::INFO)
    end

    it 'can be called with warn' do
      expect(described_class.level_from_any('warn')).to eq(::Logger::WARN)
    end

    it 'can be called with error' do
      expect(described_class.level_from_any('error')).to eq(::Logger::ERROR)
    end

    it 'can be called with error' do
      expect(described_class.level_from_any('fatal')).to eq(::Logger::FATAL)
    end

    it 'can be called with unknown' do
      expect(described_class.level_from_any('unknown')).to eq(::Logger::UNKNOWN)
    end

    it 'cannot be called with random' do
      expect { described_class.level_from_any('random') }.to raise_error(ArgumentError)
    end
  end
end
