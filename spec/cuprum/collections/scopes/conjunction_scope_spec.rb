# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/scopes/conjunction_examples'
require 'cuprum/collections/scopes/conjunction_scope'
require 'cuprum/collections/scopes/criteria_scope'

RSpec.describe Cuprum::Collections::Scopes::ConjunctionScope do
  include Cuprum::Collections::RSpec::Deferred::Scopes::ConjunctionExamples

  subject(:scope) { described_class.new(scopes:) }

  let(:scopes) { [] }

  define_method :build_scope do |*args, **kwargs, &block|
    Cuprum::Collections::Scope.new(*args, **kwargs, &block)
  end

  include_deferred 'should implement the ConjunctionScope methods',
    abstract: true
end
