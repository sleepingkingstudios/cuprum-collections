# frozen_string_literal: true

require 'cuprum/collections/basic/scopes/all_scope'
require 'cuprum/collections/basic/scopes/builder'
require 'cuprum/collections/basic/scopes/conjunction_scope'
require 'cuprum/collections/basic/scopes/criteria_scope'
require 'cuprum/collections/basic/scopes/disjunction_scope'
require 'cuprum/collections/basic/scopes/negation_scope'
require 'cuprum/collections/basic/scopes/none_scope'
require 'cuprum/collections/rspec/contracts/scopes/builder_contracts'
require 'cuprum/collections/scopes/criteria_scope'

RSpec.describe Cuprum::Collections::Basic::Scopes::Builder do
  include Cuprum::Collections::RSpec::Contracts::Scopes::BuilderContracts

  subject(:builder) { described_class.instance }

  def build_scope
    Cuprum::Collections::Scopes::CriteriaScope.build({ 'ok' => true })
  end

  include_contract 'should be a scope builder',
    all_class:         Cuprum::Collections::Basic::Scopes::AllScope,
    conjunction_class: Cuprum::Collections::Basic::Scopes::ConjunctionScope,
    criteria_class:    Cuprum::Collections::Basic::Scopes::CriteriaScope,
    disjunction_class: Cuprum::Collections::Basic::Scopes::DisjunctionScope,
    negation_class:    Cuprum::Collections::Basic::Scopes::NegationScope,
    none_class:        Cuprum::Collections::Basic::Scopes::NoneScope
end
