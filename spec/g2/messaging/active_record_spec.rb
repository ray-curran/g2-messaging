require 'spec_helper'

describe Messaging::ActiveRecord do
  subject { fake_model.new }

  let(:fake_model) do
    Class.new do
      def self.after_commit(*args); end

      def id
        :id
      end

      def attributes
        { a: 1, b: 2, c: 3 }
      end
    end
  end

  describe '#included' do
    it 'sets up post_to_messaging on after_commit - but only once (per dev autoload)' do
      expect(fake_model).to receive(:after_commit).with(:post_to_messaging)
      fake_model.send :include, Messaging::ActiveRecord

      expect(fake_model).to_not receive(:after_commit).with(:post_to_messaging)
      fake_model.send :include, Messaging::ActiveRecord
    end
  end

  context 'when mixed into model' do
    before do
      fake_model.send :include, Messaging::ActiveRecord
      allow(subject).to receive_message_chain(:class, :model_name, :name) { 'FakeModel' }
      allow(subject).to receive_message_chain(:class, :model_name, :param_key) { 'fake_model' }
    end

    describe '#post_to_messaging' do
      it 'calls out to async producer' do
        expect(Messaging::Producer).to receive(:produce).with("{\"model\":\"FakeModel\",\"data\":{\"a\":1,\"b\":2,\"c\":3}}", {:topic=>"catalog-changes", :key=>"fake_model-id"})
        subject.post_to_messaging
      end
    end

    describe '#post_to_messaging!' do
      it 'calls out to sync producer' do
        expect(Messaging::Producer).to receive(:produce!).with("{\"model\":\"FakeModel\",\"data\":{\"a\":1,\"b\":2,\"c\":3}}", {:topic=>"catalog-changes", :key=>"fake_model-id"})
        subject.post_to_messaging!
      end
    end
  end
end
