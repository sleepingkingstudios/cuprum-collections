# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/scopes/conjunction_examples'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/conjunction'
require 'cuprum/collections/scopes/criteria_scope'

RSpec.describe Cuprum::Collections::Scopes::Conjunction do
  include Cuprum::Collections::RSpec::Deferred::Scopes::ConjunctionExamples

  subject(:scope) { described_class.new(scopes:) }

  let(:described_class) { Spec::ExampleScope }
  let(:scopes)          { [] }

  example_class 'Spec::ExampleScope', Cuprum::Collections::Scopes::Base \
  do |klass|
    klass.include Cuprum::Collections::Scopes::Conjunction # rubocop:disable RSpec/DescribedClass
  end

  define_method :build_scope do |*args, **kwargs, &block|
    Cuprum::Collections::Scope.new(*args, **kwargs, &block)
  end

  include_deferred 'should implement the ConjunctionScope methods',
    abstract: true
end
