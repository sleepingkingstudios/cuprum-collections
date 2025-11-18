# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/scopes/all_examples'
require 'cuprum/collections/scopes/all'
require 'cuprum/collections/scopes/base'

RSpec.describe Cuprum::Collections::Scopes::All do
  include Cuprum::Collections::RSpec::Contracts::ScopeContracts
  include Cuprum::Collections::RSpec::Deferred::Scopes::AllExamples

  let(:described_class) { Spec::ExampleScope }

  example_class 'Spec::ExampleScope', Cuprum::Collections::Scopes::Base \
  do |klass|
    klass.include Cuprum::Collections::Scopes::All # rubocop:disable RSpec/DescribedClass
  end

  include_deferred 'should implement the AllScope methods', abstract: true
end
