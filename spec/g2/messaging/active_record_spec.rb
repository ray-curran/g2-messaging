require 'spec_helper'
require 'ostruct'

describe Messaging::ActiveRecord do
  subject { fake_model.new }

  before do
    Messaging::SchemaLoader.new(SchemaTools.schema_path).load_all
  end

  let(:fake_model) do
    Class.new do
      def self.name
        'FakeModel'
      end

      def self.after_commit(*args); end

      def self.model_name
        OpenStruct.new(name: 'FakeModel', param_key: 'fake_model')
      end

      # creating classes this way breaks extend behavior
      def self.schema_name
        model_name.param_key
      end

      def id
        1
      end

      def name
        'name'
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
    before { fake_model.send :include, Messaging::ActiveRecord }

    it 'respond to schema_name' do
      expect(fake_model.schema_name).to eq 'fake_model'
    end

    describe '#post_to_messaging' do
      it 'calls out to async producer' do
        expect(Messaging::Producer).to receive(:produce).with(
          '{"schema_model":"messages/changed_records/fake_model","model":"FakeModel","data":{"id":1,"name":"name"}}',
          topic: 'catalog-changes', key: 'fake_model-1'
        )
        subject.post_to_messaging
      end

      context 'with invalid values' do
        it 'raises a validation error' do
          allow(subject).to receive(:id).and_return nil
          expect { subject.post_to_messaging }.to raise_error(Messaging::ValidationError)
        end
      end
    end

    describe '#post_to_messaging!' do
      it 'calls out to sync producer' do
        expect(Messaging::Producer).to receive(:produce!).with(
          '{"schema_model":"messages/changed_records/fake_model","model":"FakeModel","data":{"id":1,"name":"name"}}',
          topic: 'catalog-changes', key: 'fake_model-1'
        )
        subject.post_to_messaging!
      end
    end

    describe '#post_to_messaging_klass' do
      it 'users model_name to find class' do
        expect(subject.post_to_messaging_klass).to eq Messages::ChangedRecords::FakeModel
      end
    end
  end
end
