# frozen_string_literal: true

require 'cuprum/collections/basic'

RSpec.describe Cuprum::Collections::Basic do
  describe '.new' do
    let(:collection_name) { 'books' }
    let(:data)            { [] }
    let(:options)         { { key: 'value' } }
    let(:constructor_options) do
      {
        collection_name: collection_name,
        data:            data,
        **options
      }
    end
    let(:collection) { described_class.new(**constructor_options) }

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_any_keywords
    end

    it { expect(collection).to be_a described_class::Collection }

    it { expect(collection.collection_name).to be == collection_name }

    it { expect(collection.data).to be == data }

    it { expect(collection.options).to be == options }
  end
end
