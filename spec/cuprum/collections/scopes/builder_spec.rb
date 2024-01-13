# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/scopes/builder_contracts'
require 'cuprum/collections/scopes/builder'

RSpec.describe Cuprum::Collections::Scopes::Builder do
  include Cuprum::Collections::RSpec::Contracts::Scopes::BuilderContracts

  subject(:builder) { described_class.instance }

  def build_scope
    Cuprum::Collections::Scope.new({ 'ok' => true })
  end

  describe '.instance' do
    it { expect(described_class).to respond_to(:instance).with(0).arguments }

    it { expect(described_class.instance).to be_a described_class }

    it { expect(described_class.instance).to be builder }
  end

  include_contract 'should be a scope builder',
    conjunction_class: Cuprum::Collections::Scopes::ConjunctionScope,
    criteria_class:    Cuprum::Collections::Scopes::CriteriaScope,
    disjunction_class: Cuprum::Collections::Scopes::DisjunctionScope,
    negation_class:    Cuprum::Collections::Scopes::NegationScope
end
