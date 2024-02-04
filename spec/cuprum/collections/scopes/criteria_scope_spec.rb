# frozen_string_literal: true

require 'cuprum/collections/scopes/criteria_scope'
require 'cuprum/collections/rspec/contracts/scopes/criteria_contracts'

RSpec.describe Cuprum::Collections::Scopes::CriteriaScope do
  include Cuprum::Collections::RSpec::Contracts::Scopes::CriteriaContracts

  subject(:scope) do
    described_class.new(criteria: criteria, **constructor_options)
  end

  let(:criteria)            { [] }
  let(:constructor_options) { {} }

  include_contract 'should be a criteria scope', abstract: true
end
