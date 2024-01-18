# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/scope_contracts'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/null'

RSpec.describe Cuprum::Collections::Scopes::Null do
  include Cuprum::Collections::RSpec::Contracts::ScopeContracts

  let(:described_class) { Spec::ExampleScope }

  example_class 'Spec::ExampleScope', Cuprum::Collections::Scopes::Base \
  do |klass|
    klass.include Cuprum::Collections::Scopes::Null # rubocop:disable RSpec/DescribedClass
  end

  include_contract 'should be a null scope', abstract: true
end
