# frozen_string_literal: true

require 'cuprum/collections/errors/not_found'

RSpec.describe Cuprum::Collections::Errors::NotFound do
  subject(:error) do
    described_class.new(
      collection_name:    collection_name,
      primary_key_name:   primary_key_name,
      primary_key_values: primary_key_values
    )
  end

  let(:collection_name)    { 'books' }
  let(:primary_key_name)   { 'id' }
  let(:primary_key_values) { 0 }

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.collections.errors.not_found'
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:collection_name, :primary_key_name, :primary_key_values)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {
          'collection_name'    => error.collection_name,
          'primary_key_name'   => error.primary_key_name,
          'primary_key_values' => error.primary_key_values
        },
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should define reader', :as_json, -> { expected }
  end

  describe '#collection_name' do
    include_examples 'should define reader',
      :collection_name,
      -> { collection_name }
  end

  describe '#message' do
    let(:expected) { 'Book not found with id 0' }

    include_examples 'should define reader', :message, -> { be == expected }

    context 'when initialized with primary_key_values: an Array' do
      let(:primary_key_values) { [1, 2, 3] }
      let(:expected)           { 'Books not found with id 1, 2, 3' }

      it { expect(error.message).to be == expected }
    end
  end

  describe '#primary_key_name' do
    include_examples 'should define reader',
      :primary_key_name,
      -> { primary_key_name }
  end

  describe '#primary_key_values' do
    include_examples 'should define reader',
      :primary_key_values,
      -> { [primary_key_values] }

    context 'when initialized with primary_key_values: an Array' do
      let(:primary_key_values) { [1, 2, 3] }

      it { expect(error.primary_key_values).to be == primary_key_values }
    end
  end

  describe '#type' do
    include_examples 'should define reader', :type, described_class::TYPE
  end
end
