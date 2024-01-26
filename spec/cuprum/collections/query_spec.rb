# frozen_string_literal: true

require 'cuprum/collections/query'
require 'cuprum/collections/rspec/contracts/query_contracts'

RSpec.describe Cuprum::Collections::Query do
  include Cuprum::Collections::RSpec::Contracts::QueryContracts

  subject(:query) { described_class.new(scope: initial_scope) }

  let(:initial_scope) { nil }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:scope)
    end
  end

  include_contract 'should be a query', abstract: true

  describe '#scope' do
    it 'should define the default scope' do
      expect(query.scope).to be_a Cuprum::Collections::Scopes::NullScope
    end

    wrap_context 'when initialized with a scope' do
      it 'should transform the scope' do
        expect(query.scope).to be_a Cuprum::Collections::Scopes::CriteriaScope
      end
    end
  end
end
