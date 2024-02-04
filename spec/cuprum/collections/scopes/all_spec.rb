# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/scope_contracts'
require 'cuprum/collections/scopes/all'
require 'cuprum/collections/scopes/base'

RSpec.describe Cuprum::Collections::Scopes::All do
  include Cuprum::Collections::RSpec::Contracts::ScopeContracts

  let(:described_class) { Spec::ExampleScope }

  example_class 'Spec::ExampleScope', Cuprum::Collections::Scopes::Base \
  do |klass|
    klass.include Cuprum::Collections::Scopes::All # rubocop:disable RSpec/DescribedClass
  end

  include_contract 'should be an all scope', abstract: true
end
