# frozen_string_literal: true

require 'cuprum/collections/basic'

RSpec.describe Cuprum::Collections::Basic do
  describe '.new' do
    let(:name)    { 'books' }
    let(:data)    { [] }
    let(:options) { { key: 'value' } }
    let(:constructor_options) do
      {
        name:,
        data:,
        **options
      }
    end
    let(:collection)       { described_class.new(**constructor_options) }
    let(:expected_options) { options.merge(default_entity_class: Hash) }

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_any_keywords
    end

    it { expect(collection).to be_a described_class::Collection }

    it { expect(collection.data).to be == data }

    it { expect(collection.name).to be == name }

    it { expect(collection.options).to be == expected_options }
  end
end
