# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/scopes/logical_contracts'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/conjunction'
require 'cuprum/collections/scopes/criteria_scope'

RSpec.describe Cuprum::Collections::Scopes::Conjunction do
  include Cuprum::Collections::RSpec::Contracts::Scopes::LogicalContracts

  subject(:scope) { described_class.new(scopes: scopes) }

  let(:described_class) { Spec::ExampleScope }
  let(:scopes)          { [] }

  example_class 'Spec::ExampleScope', Cuprum::Collections::Scopes::Base \
  do |klass|
    klass.include Cuprum::Collections::Scopes::Conjunction # rubocop:disable RSpec/DescribedClass
  end

  def build_scope(...)
    Cuprum::Collections::Scope.new(...)
  end

  include_contract 'should be a conjunction scope', abstract: true
end
