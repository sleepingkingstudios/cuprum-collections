# frozen_string_literal: true

require 'cuprum/collections/basic/collection'
require 'cuprum/collections/basic/commands'
require 'cuprum/collections/rspec/deferred/collection_examples'
require 'cuprum/collections/rspec/fixtures'

require 'support/book'
require 'support/grimoire'
require 'support/scoped_book'

RSpec.describe Cuprum::Collections::Basic::Collection do
  include Cuprum::Collections::RSpec::Deferred::CollectionExamples

  subject(:collection) do
    described_class.new(
      data:,
      **constructor_options
    )
  end

  shared_context 'when the collection has many items' do
    let(:data)  { Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.dup }
    let(:items) { data }
  end

  let(:name)                { 'books' }
  let(:data)                { [] }
  let(:constructor_options) { { name: } }
  let(:query_class)         { Cuprum::Collections::Basic::Query }
  let(:query_options)       { { data: } }

  describe '.new' do
    def call_method(**parameters)
      described_class.new(data:, **parameters)
    end

    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:data, :entity_class, :name, :qualified_name)
        .and_any_keywords
    end

    include_deferred 'should validate the Relation parameters'
  end

  include_deferred 'should be a Collection',
    commands_namespace:   'Cuprum::Collections::Basic::Commands',
    default_entity_class: Hash,
    default_scope:        Cuprum::Collections::Basic::Scopes::AllScope

  describe '#data' do
    include_examples 'should define reader', :data, -> { data }
  end

  describe '#default_contract' do
    include_examples 'should define reader', :default_contract, nil

    context 'when initialized with default_contract: value' do
      let(:default_contract) { Stannum::Contract.new }
      let(:constructor_options) do
        super().merge(default_contract:)
      end

      it { expect(collection.default_contract).to be default_contract }
    end
  end

  describe '#name' do
    context 'when initialized with qualified_name: value' do
      let(:qualified_name)      { 'books' }
      let(:constructor_options) { { qualified_name: } }

      it { expect(collection.name).to be == 'books' }
    end

    context 'when initialized with qualified_name: scoped value' do
      let(:qualified_name)      { 'spec/scoped_books' }
      let(:constructor_options) { { qualified_name: } }

      it { expect(collection.name).to be == 'scoped_books' }
    end
  end

  describe '#query' do
    it 'should define the default scope' do
      expect(collection.query.scope)
        .to be_a Cuprum::Collections::Basic::Scopes::AllScope
    end
  end
end
