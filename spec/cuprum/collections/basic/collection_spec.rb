# frozen_string_literal: true

require 'cuprum/collections/basic/collection'
require 'cuprum/collections/basic/commands'
require 'cuprum/collections/rspec/contracts/collection_contracts'
require 'cuprum/collections/rspec/fixtures'

require 'support/book'
require 'support/grimoire'
require 'support/scoped_book'

RSpec.describe Cuprum::Collections::Basic::Collection do
  include Cuprum::Collections::RSpec::Contracts::CollectionContracts

  subject(:collection) do
    described_class.new(
      data: data,
      **constructor_options
    )
  end

  shared_context 'when the collection has many items' do
    let(:data)  { Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.dup }
    let(:items) { data }
  end

  let(:name)                { 'books' }
  let(:data)                { [] }
  let(:constructor_options) { { name: name } }
  let(:query_class)         { Cuprum::Collections::Basic::Query }
  let(:query_options)       { { data: data } }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:data, :entity_class, :name, :qualified_name)
        .and_any_keywords
    end
  end

  include_contract 'should be a collection',
    command_options:      %i[data default_contract],
    commands_namespace:   'Cuprum::Collections::Basic::Commands',
    default_entity_class: Hash

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

  describe '#query' do
    it 'should define the default scope' do
      expect(collection.query.scope)
        .to be_a Cuprum::Collections::Basic::Scopes::NullScope
    end
  end

  describe '#scope' do
    it 'should define the default scope' do
      expect(collection.scope)
        .to be_a Cuprum::Collections::Basic::Scopes::NullScope
    end

    wrap_context 'when initialized with a scope' do
      it 'should transform the scope' do
        expect(collection.scope)
          .to be_a Cuprum::Collections::Basic::Scopes::CriteriaScope
      end
    end
  end

  describe '#with_scope' do
    let(:other_scope) do
      Cuprum::Collections::Scope.new({ 'secret' => '12345' })
    end
    let(:copy) { subject.with_scope(other_scope) }

    it 'should transform the scope' do
      expect(copy.scope)
        .to be_a Cuprum::Collections::Basic::Scopes::CriteriaScope
    end

    wrap_context 'when initialized with a scope' do
      it 'should transform the scope' do
        expect(copy.scope)
          .to be_a Cuprum::Collections::Basic::Scopes::CriteriaScope
      end
    end
  end
end
