# frozen_string_literal: true

require 'bronze/scopes/conjunction_scope'
require 'bronze/scopes/criteria_scope'
require 'bronze/rspec/deferred/scopes/conjunction_examples'

RSpec.describe Bronze::Scopes::ConjunctionScope do
  include Bronze::RSpec::Deferred::Scopes::ConjunctionExamples

  subject(:scope) { described_class.new(scopes:) }

  let(:scopes) { [] }

  define_method :build_scope do |*args, **kwargs, &block|
    Bronze::Scope.new(*args, **kwargs, &block)
  end

  include_deferred 'should implement the ConjunctionScope methods',
    abstract: true
end
