# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/scopes/composition_contracts'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/composition/criteria'
require 'cuprum/collections/scopes/criteria'
require 'cuprum/collections/scopes/criteria_scope'

RSpec.describe Cuprum::Collections::Scopes::Composition::Criteria do
  include Cuprum::Collections::RSpec::Contracts::Scopes::CompositionContracts

  subject(:scope) { described_class.new(criteria: criteria) }

  let(:described_class) { Spec::ExampleScope }
  let(:criteria)        { [] }

  example_class 'Spec::ExampleScope', Cuprum::Collections::Scopes::Base \
  do |klass|
    klass.include Cuprum::Collections::Scopes::Criteria
    klass.include Cuprum::Collections::Scopes::Composition::Criteria # rubocop:disable RSpec/DescribedClass

    klass.define_method(:type) { :criteria }
  end

  include_contract 'should compose scopes for criteria'
end
