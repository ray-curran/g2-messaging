require 'g2/messaging/producer'

describe Messaging::Producer do
  let(:producer) { double(produce: true, deliver_messages: true, shutdown: false) }
  let(:kafka_client) { double(async_producer: producer, producer: producer) }
  let(:value) { 'value' }
  let(:topic) { Messaging::Producer.config.prefix + 'topic' }

  before do
    allow(Messaging::Producer).to receive(:kafka_client).and_return(kafka_client)
  end

  after do
    Messaging::Producer.reset
  end

  it 'should have prepared cleanup' do
    expect(Messaging::Producer).to receive(:prepare_cleanup).and_call_original.at_least(1)
    Messaging::Producer.async_pool
  end

  it 'should have created ConnectionPool' do
    expect(ConnectionPool).to receive(:new).and_call_original.at_least(1)
  end
end
