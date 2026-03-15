# frozen_string_literal: true

require 'bronze/scopes/base'
require 'bronze/scopes/criteria_scope'
require 'bronze/scopes/disjunction'
require 'cuprum/collections/rspec/deferred/scopes/disjunction_examples'

RSpec.describe Bronze::Scopes::Disjunction do
  include Cuprum::Collections::RSpec::Deferred::Scopes::DisjunctionExamples

  subject(:scope) { described_class.new(scopes:) }

  let(:described_class) { Spec::ExampleScope }
  let(:scopes)          { [] }

  example_class 'Spec::ExampleScope', Bronze::Scopes::Base do |klass|
    klass.include Bronze::Scopes::Disjunction # rubocop:disable RSpec/DescribedClass
  end

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
