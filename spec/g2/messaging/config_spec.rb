require 'g2/messaging/config'

describe Messaging::Config do
  subject { Messaging::Config.new }
  let(:logger) { double }
  it 'should have default url' do
    expect(subject.url).to eq 'kafka:9092'
  end
  context 'when Rails' do
    let(:rails) { double(logger: true) }
    before do
      Rails ||= rails
    end

    after do
      Rails = nil if Rails == rails
    end

    it 'should call rails logger' do
      allow(Rails).to receive(:logger)
      expect(subject.logger).to eq rails.logger
    end
  end
end
