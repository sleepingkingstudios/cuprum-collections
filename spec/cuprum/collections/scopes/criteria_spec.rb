# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/scopes/criteria_scope_examples'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/criteria'

RSpec.describe Cuprum::Collections::Scopes::Criteria do
  include Cuprum::Collections::RSpec::Deferred::Scopes::CriteriaScopeExamples

  subject(:scope) do
    described_class.new(criteria:, **constructor_options)
  end

  let(:described_class)     { Spec::ExampleScope }
  let(:constructor_options) { {} }

  example_class 'Spec::ExampleScope', Cuprum::Collections::Scopes::Base \
  do |klass|
    klass.include Cuprum::Collections::Scopes::Criteria # rubocop:disable RSpec/DescribedClass
  end

  include_deferred 'should be a CriteriaScope', abstract: true
end
