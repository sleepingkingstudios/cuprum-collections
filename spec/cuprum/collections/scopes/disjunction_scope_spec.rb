# frozen_string_literal: true

require 'cuprum/collections/scopes/disjunction_scope'
require 'cuprum/collections/rspec/contracts/scopes/logical_contracts'

RSpec.describe Cuprum::Collections::Scopes::DisjunctionScope do
  include Cuprum::Collections::RSpec::Contracts::Scopes::LogicalContracts

  subject(:scope) { described_class.new(scopes: scopes) }

  let(:scopes) { [] }

  include_contract 'should be a disjunction scope', abstract: true
end
