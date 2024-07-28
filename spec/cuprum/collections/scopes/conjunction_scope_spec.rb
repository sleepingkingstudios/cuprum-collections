# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/scopes/logical_contracts'
require 'cuprum/collections/scopes/conjunction_scope'
require 'cuprum/collections/scopes/criteria_scope'

RSpec.describe Cuprum::Collections::Scopes::ConjunctionScope do
  include Cuprum::Collections::RSpec::Contracts::Scopes::LogicalContracts

  subject(:scope) { described_class.new(scopes:) }

  let(:scopes) { [] }

  def build_scope(...)
    Cuprum::Collections::Scope.new(...)
  end

  include_contract 'should be a conjunction scope', abstract: true
end
