require 'spec_helper'

describe Messaging::SchemaLoader do
  subject { Messaging::SchemaLoader.new(path) }

  context 'with path to schema files' do
    let(:path) { './spec/fixtures/schema/models' }

    describe '#load_all' do
      before do
        subject.load_all
      end

      it 'creates an activemodel-style object with validations for each schema' do
        expect(Messages::FakeModel).to be_a Class
        expect(Messages::FakeModel.new).to_not be_valid
        expect(Messages::FakeModel.new).to respond_to(:id)
        expect(Messages::FakeModel.new).to respond_to(:name)
        expect(Messages::FakeModel.new(id: 1, name: 'test')).to be_valid
      end
    end
  end
end
