require 'g2/messaging/logger'
require 'logger'

describe Messaging::Logger do

  context 'when logger defined' do
    subject { Messaging::Logger.new(logger) }
    let(:logger) { double }
    let(:message) { "defined" }

    it 'should delegate to passed in logger' do
      expect(logger).to receive(:info).with("[kafka] #{message}")
      subject.info(message)
    end
  end

  context 'when logger undefined' do
    subject { Messaging::Logger.new(nil) }

    it 'should not fail' do
      subject.info('testing logger')
    end
  end
end
