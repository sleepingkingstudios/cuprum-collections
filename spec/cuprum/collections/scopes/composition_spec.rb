# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/scopes/composition_contracts'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/composition'

RSpec.describe Cuprum::Collections::Scopes::Composition do
  include Cuprum::Collections::RSpec::Contracts::Scopes::CompositionContracts

  subject(:scope) { described_class.new }

  let(:described_class) { Spec::ExampleScope }

  example_class 'Spec::ExampleScope', Cuprum::Collections::Scopes::Base

  include_contract 'should compose scopes'
end
