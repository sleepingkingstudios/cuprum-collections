# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/scopes/logical_contracts'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/criteria_scope'
require 'cuprum/collections/scopes/negation'

RSpec.describe Cuprum::Collections::Scopes::Negation do
  include Cuprum::Collections::RSpec::Contracts::Scopes::LogicalContracts

  subject(:scope) { described_class.new(scopes: scopes) }

  let(:described_class) { Spec::ExampleScope }
  let(:scopes)          { [] }

  example_class 'Spec::ExampleScope', Cuprum::Collections::Scopes::Base \
  do |klass|
    klass.include Cuprum::Collections::Scopes::Negation # rubocop:disable RSpec/DescribedClass
  end

  def build_scope(filters = nil, &block)
    scope_class = Cuprum::Collections::Scopes::CriteriaScope

    if block_given?
      scope_class.build(&block)
    else
      scope_class.build(filters)
    end
  end

  include_contract 'should be a negation scope', abstract: true
end
