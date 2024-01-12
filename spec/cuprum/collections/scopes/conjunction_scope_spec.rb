# frozen_string_literal: true

require 'cuprum/collections/scopes/conjunction_scope'
require 'cuprum/collections/rspec/contracts/scopes/logical_contracts'

RSpec.describe Cuprum::Collections::Scopes::ConjunctionScope do
  include Cuprum::Collections::RSpec::Contracts::Scopes::LogicalContracts

  subject(:scope) { described_class.new(scopes: scopes) }

  let(:scopes) { [] }

  include_contract 'should be a conjunction scope', abstract: true
end
