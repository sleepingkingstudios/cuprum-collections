# frozen_string_literal: true

require 'cuprum/collections/scopes/criteria_scope'
require 'cuprum/collections/rspec/contracts/scopes/criteria_contracts'

RSpec.describe Cuprum::Collections::Scopes::CriteriaScope do
  include Cuprum::Collections::RSpec::Contracts::Scopes::CriteriaContracts

  subject(:scope) { described_class.new(criteria: criteria) }

  let(:criteria) { [] }

  include_contract 'should be a criteria scope', abstract: true
end
