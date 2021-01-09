# frozen_string_literal: true

require 'cuprum/collections/contracts/query_builder_contract'
require 'cuprum/collections/query'
require 'cuprum/collections/query_builder'

RSpec.describe Cuprum::Collections::QueryBuilder do
  subject(:builder) { described_class.new(base_query) }

  let(:base_query) { Cuprum::Collections::Query.new }

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(1).argument }
  end

  include_contract Cuprum::Collections::Contracts::QUERY_BUILDER_CONTRACT
end
