# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/scopes/builder_contracts'
require 'cuprum/collections/scopes/all_scope'
require 'cuprum/collections/scopes/builder'
require 'cuprum/collections/scopes/conjunction_scope'
require 'cuprum/collections/scopes/criteria_scope'
require 'cuprum/collections/scopes/disjunction_scope'
require 'cuprum/collections/scopes/negation_scope'
require 'cuprum/collections/scopes/none_scope'

RSpec.describe Cuprum::Collections::Scopes::Builder do
  include Cuprum::Collections::RSpec::Contracts::Scopes::BuilderContracts

  subject(:builder) { described_class.instance }

  def build_scope
    Cuprum::Collections::Scopes::CriteriaScope.build({ 'ok' => true })
  end

  include_contract 'should be a scope builder',
    all_class:         Cuprum::Collections::Scopes::AllScope,
    conjunction_class: Cuprum::Collections::Scopes::ConjunctionScope,
    criteria_class:    Cuprum::Collections::Scopes::CriteriaScope,
    disjunction_class: Cuprum::Collections::Scopes::DisjunctionScope,
    negation_class:    Cuprum::Collections::Scopes::NegationScope,
    none_class:        Cuprum::Collections::Scopes::NoneScope
end
