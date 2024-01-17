# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/scopes/logical_contracts'
require 'cuprum/collections/scopes/criteria_scope'
require 'cuprum/collections/scopes/negation_scope'

RSpec.describe Cuprum::Collections::Scopes::NegationScope do
  include Cuprum::Collections::RSpec::Contracts::Scopes::LogicalContracts

  subject(:scope) { described_class.new(scopes: scopes) }

  let(:scopes) { [] }

  def build_scope(filters = nil, &block)
    scope_class = Cuprum::Collections::Basic::Scopes::CriteriaScope

    if block_given?
      scope_class.build(&block)
    else
      scope_class.build(filters)
    end
  end

  include_contract 'should be a negation scope', abstract: true
end
