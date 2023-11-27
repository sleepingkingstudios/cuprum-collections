# frozen_string_literal: true

require 'cuprum/collections/query'
require 'cuprum/collections/query_builder'
require 'cuprum/collections/rspec/contracts/query_contracts'

RSpec.describe Cuprum::Collections::QueryBuilder do
  include Cuprum::Collections::RSpec::Contracts::QueryContracts

  subject(:builder) { described_class.new(base_query) }

  let(:base_query) { Cuprum::Collections::Query.new }

  describe '::ParseError' do
    it { expect(described_class::ParseError).to be_a Class }

    it { expect(described_class::ParseError).to be < RuntimeError }
  end

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(1).argument }
  end

  include_contract 'should be a query builder'
end
