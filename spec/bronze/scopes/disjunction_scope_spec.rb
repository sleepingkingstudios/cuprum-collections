# frozen_string_literal: true

require 'bronze/scopes/criteria_scope'
require 'bronze/scopes/disjunction_scope'
require 'cuprum/collections/rspec/deferred/scopes/disjunction_examples'

RSpec.describe Bronze::Scopes::DisjunctionScope do
  include Cuprum::Collections::RSpec::Deferred::Scopes::DisjunctionExamples

  subject(:scope) { described_class.new(scopes:) }

  let(:scopes) { [] }

  def build_scope(filters = nil, &block)
    scope_class = Bronze::Scopes::CriteriaScope

    if block_given?
      scope_class.build(&block)
    else
      scope_class.build(filters)
    end
  end

  include_deferred 'should implement the DisjunctionScope methods',
    abstract: true
end
