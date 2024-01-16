# frozen_string_literal: true

require 'cuprum/collections/scope'
require 'cuprum/collections/rspec/contracts/scopes/criteria_contracts'

RSpec.describe Cuprum::Collections::Scope do
  include Cuprum::Collections::RSpec::Contracts::Scopes::CriteriaContracts

  subject(:scope) do
    described_class.new(*constructor_args, &constructor_block)
  end

  let(:constructor_args) { [] }
  let(:constructor_block) do
    expected = criteria

    lambda do
      expected.to_h do |(attribute, operator, value)|
        [attribute, send(operator, value)]
      end
    end
  end

  describe '.new' do
    def parse_criteria(...)
      described_class.new(...).criteria
    end

    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0..1).arguments
        .and_a_block
    end

    include_contract 'should parse criteria'
  end

  include_contract 'should be a criteria scope',
    abstract:    true,
    constructor: false
end
