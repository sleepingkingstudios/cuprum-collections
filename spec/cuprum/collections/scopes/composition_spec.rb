# frozen_string_literal: true

require 'cuprum/collections/scopes/composition'
require 'cuprum/collections/rspec/contracts/scopes/composition_contracts'

RSpec.describe Cuprum::Collections::Scopes::Composition do
  include Cuprum::Collections::RSpec::Contracts::Scopes::CompositionContracts

  subject(:scope) { described_class.new }

  let(:described_class) { Spec::ExampleScope }

  example_class 'Spec::ExampleScope', Cuprum::Collections::Scopes::Base

  include_contract 'should compose scopes'
end
