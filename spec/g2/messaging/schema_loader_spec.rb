require 'spec_helper'

describe Messaging::SchemaLoader do
  subject { Messaging::SchemaLoader.new(path) }

  context 'with path to fake schema files' do
    let(:path) { './spec/fixtures/schema' }

    describe '#load_all' do
      before do
        subject.load_all
      end

      it 'creates an activemodel-style object with validations for each schema' do
        expect(Messages::ChangedRecords::FakeModel).to be_a Class
        expect(Messages::ChangedRecords::FakeModel.new).to_not be_valid
        expect(Messages::ChangedRecords::FakeModel.new).to respond_to(:id)
        expect(Messages::ChangedRecords::FakeModel.new).to respond_to(:name)
        expect(Messages::ChangedRecords::FakeModel.new(id: 1, name: 'test')).to be_valid
      end
    end
  end

  context 'with path to actual schema files' do
    let(:path) { './schema' }

    describe '#load_all' do
      before do
        subject.load_all
      end

      it 'all json schema files are valid' do
        expect(Messages::ChangedRecords::Category).to be_a Class
        expect(Messages::ChangedRecords::Category.new).to_not be_valid
        expect(Messages::ChangedRecords::Category.new).to respond_to(:id)
        expect(Messages::ChangedRecords::Category.new).to respond_to(:name)
        expect(Messages::ChangedRecords::Category.new(id: 1, name: 'test')).to be_valid
      end
    end
  end
end
