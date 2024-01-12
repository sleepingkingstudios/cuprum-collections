# frozen_string_literal: true

require 'cuprum/collections/scopes/negation_scope'
require 'cuprum/collections/rspec/contracts/scopes/logical_contracts'

RSpec.describe Cuprum::Collections::Scopes::NegationScope do
  include Cuprum::Collections::RSpec::Contracts::Scopes::LogicalContracts

  subject(:scope) { described_class.new(scopes: scopes) }

  let(:scopes) { [] }

  include_contract 'should be a negation scope', abstract: true
end
