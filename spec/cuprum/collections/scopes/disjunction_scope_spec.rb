# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/scopes/logical_contracts'
require 'cuprum/collections/scopes/criteria_scope'
require 'cuprum/collections/scopes/disjunction_scope'

RSpec.describe Cuprum::Collections::Scopes::DisjunctionScope do
  include Cuprum::Collections::RSpec::Contracts::Scopes::LogicalContracts

  subject(:scope) { described_class.new(scopes:) }

  let(:scopes) { [] }

  def build_scope(filters = nil, &block)
    scope_class = Cuprum::Collections::Scopes::CriteriaScope

    if block_given?
      scope_class.build(&block)
    else
      scope_class.build(filters)
    end
  end

  include_contract 'should be a disjunction scope', abstract: true
end
