require 'spec_helper'

describe Messaging::Backends::Inline do
  subject do
    klass = Class.new

    klass.class_eval do
      include Messaging::Backends::Controller
      attr_reader :received_value

      handle Messages::ChangedRecords::FakeModel do |message|
        @received_value = message
      end
    end

    klass.new
  end

  let(:message) { double('Message', value: data.to_json, key: '123') }

  describe '#perform' do
    let(:data) { { schema_model: 'messages/changed_records/fake_model', data: { id: 1, name: 'Test Message' } } }

    context 'given a message with a handler' do
      it 'routes the message through' do
        subject.perform(message.value, message.key)
        expect(subject.received_value).to be_a(Messages::ChangedRecords::FakeModel)
      end
    end

    context 'given an unrecognized message' do
      let(:data) { { schema_model: 'messages/non_existent', data: { id: 1, name: 'Test Message' } } }
      it 'quietly ignores the message' do
        subject.perform(message.value, message.key)
        expect(subject.received_value).to be_nil
      end
    end

    context 'given invalid JSON' do
      let(:message) { double('Message', value: "{invalid", key: '123') }

      it 'reports to monitoring' do
        expect(Messaging.config.error_reporter).to receive(:call)
        subject.perform(message.value, message.key)
      end
    end

    context 'given invalid schema' do
      let(:data) { { unexpected: :values } }
      it 'reports to monitoring' do
        expect(Messaging.config.error_reporter).to receive(:call)
        subject.perform(message.value, message.key)
      end
    end
  end
end
