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
end
