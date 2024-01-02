# frozen_string_literal: true

require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/container'
require 'cuprum/collections/rspec/contracts/scope_contracts'

RSpec.describe Cuprum::Collections::Scopes::Container do
  include Cuprum::Collections::RSpec::Contracts::ScopeContracts

  subject(:scope) { described_class.new(scopes: scopes) }

  let(:described_class) { Spec::ExampleScope }
  let(:scopes)          { [] }

  example_class 'Spec::ExampleScope', Cuprum::Collections::Scopes::Base \
  do |klass|
    klass.include Cuprum::Collections::Scopes::Container # rubocop:disable RSpec/DescribedClass
  end

  include_contract 'should be a container scope'
end
