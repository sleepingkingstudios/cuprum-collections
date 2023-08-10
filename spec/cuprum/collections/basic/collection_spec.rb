# frozen_string_literal: true

require 'cuprum/collections/basic/collection'
require 'cuprum/collections/basic/commands'
require 'cuprum/collections/rspec/collection_contract'
require 'cuprum/collections/rspec/fixtures'

RSpec.describe Cuprum::Collections::Basic::Collection do
  subject(:collection) do
    described_class.new(
      data: data,
      **constructor_options
    )
  end

  shared_context 'when the collection has many items' do
    let(:data)  { Cuprum::Collections::RSpec::BOOKS_FIXTURES }
    let(:items) { data }
  end

  let(:collection_name)     { 'books' }
  let(:data)                { [] }
  let(:constructor_options) { { collection_name: collection_name } }
  let(:query_class)         { Cuprum::Collections::Basic::Query }
  let(:query_options)       { { data: data } }

  example_class 'Book',             'Hash'
  example_class 'Grimoire',         'Book'
  example_class 'Spec::ScopedBook', 'Book'

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:collection_name, :data)
        .and_any_keywords
    end
  end

  include_contract Cuprum::Collections::RSpec::CollectionContract,
    command_options:    %i[data default_contract],
    commands_namespace: 'Cuprum::Collections::Basic::Commands',
    entity_class:       Hash

  describe '#data' do
    include_examples 'should define reader', :data, -> { data }
  end

  describe '#default_contract' do
    include_examples 'should define reader', :default_contract, nil

    context 'when initialized with default_contract: value' do
      let(:default_contract) { Stannum::Contract.new }
      let(:constructor_options) do
        super().merge(default_contract: default_contract)
      end

      it { expect(collection.default_contract).to be default_contract }
    end
  end
end
