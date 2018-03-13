require 'g2/messaging/consumer'

describe Messaging::Consumer do
  let(:producer) { double(produce: true, deliver_messages: true, shutdown: false) }
  let(:kafka_client) { double(async_producer: producer, producer: producer) }

  before do
    allow(Messaging::Consumer).to receive(:kafka_client).and_return(kafka_client)
  end

  after do
    Messaging::Consumer.reset
  end

  it 'should have prepared cleanup' do
    expect(Messaging::Consumer).to receive(:prepare_cleanup).and_call_original.at_least(1)
    Messaging::Consumer.pool
  end

  it 'should have created ConnectionPool' do
    expect(ConnectionPool).to receive(:new).and_call_original.at_least(1)
    Messaging::Consumer.pool
  end

  context 'when ruby' do
    before { stub_const('RUBY_ENGINE', 'ruby') }

    it 'should trap signals' do
      expect(Messaging::Consumer).to receive(:shut_your_trap).with('QUIT').at_least(1).and_call_original
      expect(Messaging::Consumer).to receive(:shut_your_trap).with('TERM').at_least(1).and_call_original
      expect(Messaging::Consumer).to receive(:shut_your_trap).with('INT').at_least(1).and_call_original
      Messaging::Consumer.pool
    end
  end

  context 'when jruby' do
    before { stub_const('RUBY_ENGINE', 'jruby') }

    it 'should trap signals' do
      expect(Messaging::Consumer).not_to receive(:shut_your_trap).with('QUIT').and_call_original
      expect(Messaging::Consumer).not_to receive(:shut_your_trap).with('TERM').and_call_original
      expect(Messaging::Consumer).to receive(:shut_your_trap).with('INT').at_least(1).and_call_original
      Messaging::Consumer.pool
    end
  end
end
