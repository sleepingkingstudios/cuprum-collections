# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/scopes/composition_contracts'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/composition/disjunction'
require 'cuprum/collections/scopes/container'
require 'cuprum/collections/scopes/criteria_scope'

RSpec.describe Cuprum::Collections::Scopes::Composition::Disjunction do
  include Cuprum::Collections::RSpec::Contracts::Scopes::CompositionContracts

  subject(:scope) { described_class.new(scopes: scopes) }

  let(:described_class) { Spec::ExampleScope }
  let(:scopes)          { [] }

  example_class 'Spec::ExampleScope', Cuprum::Collections::Scopes::Base \
  do |klass|
    klass.include Cuprum::Collections::Scopes::Container
    klass.include Cuprum::Collections::Scopes::Composition::Disjunction # rubocop:disable RSpec/DescribedClass

    klass.define_method(:type) { :disjunction }
  end

  def build_scope(filters = nil, &block)
    scope_class = Cuprum::Collections::Basic::Scopes::CriteriaScope

    if block_given?
      scope_class.build(&block)
    else
      scope_class.build(filters)
    end
  end

  include_contract 'should compose scopes for disjunction'
end
