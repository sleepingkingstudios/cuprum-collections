# frozen_string_literal: true

require 'bronze/scopes/base'
require 'bronze/scopes/conjunction'
require 'bronze/scopes/criteria_scope'
require 'cuprum/collections/rspec/deferred/scopes/conjunction_examples'

RSpec.describe Bronze::Scopes::Conjunction do
  include Cuprum::Collections::RSpec::Deferred::Scopes::ConjunctionExamples

  subject(:scope) { described_class.new(scopes:) }

  let(:described_class) { Spec::ExampleScope }
  let(:scopes)          { [] }

  example_class 'Spec::ExampleScope', Bronze::Scopes::Base do |klass|
    klass.include Bronze::Scopes::Conjunction # rubocop:disable RSpec/DescribedClass
  end

  define_method :build_scope do |*args, **kwargs, &block|
    Bronze::Scope.new(*args, **kwargs, &block)
  end

  include_deferred 'should implement the ConjunctionScope methods',
    abstract: true
end
